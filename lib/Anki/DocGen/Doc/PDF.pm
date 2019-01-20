package Anki::DocGen::Doc::PDF;
# ABSTRACT: A PDF document

use Modern::Perl;
use Mu;
use Function::Parameters;

use Tree::DAG_Node;

use Encode qw(decode_utf8);
use Capture::Tiny qw(capture_stdout);
use List::UtilsBy qw(min_by);

use Renard::Block::Format::PDF::Document;

use constant PDFTOTEXT_PATH => 'pdftotext';

extends qw(Anki::DocGen::Doc);

lazy basename => method() {
	$self->filename->basename(qw(.pdf));
};

lazy _renard_doc =>
	method() {
		Renard::Block::Format::PDF::Document->new(
			filename => $self->filename
		);
	},
	(
		handles => [ qw(number_of_pages) ],
	);

method get_rendered_png_data(@) {
	$self->_renard_doc->get_rendered_page( @_ )->png_data;
}

lazy outline_tree => method() {
	my $root = Tree::DAG_Node->new({ attributes => { level => -1, page => 1, text => $self->basename } });
	my $items = $self->_renard_doc->outline->items;
	my $current = $root;

	for my $item_data (@$items) {
		next if ! exists $item_data->{page};
		my $item = Tree::DAG_Node->new({ attributes => $item_data });

		while( $current->mother && $item->attributes->{level} < $current->attributes->{level} ) {
			$current = $current->mother;
		}

		if( $item->attributes->{level} > $current->attributes->{level} ) {
			$current->add_daughter( $item );
			$current = $item;
		} else {
			$current->add_right_sister( $item );
			$current = $item;
		}
	}

	$root;
};

lazy _heading_data => method() {
	my $tree = $self->outline_tree;
	my $data;
	$tree->walk_down({
		callback => sub {
			my ($node) = @_;
			if($node->attributes->{text}) {
				my $parent = $node;
				my @parent_text;
				do {
					unshift @parent_text, $parent->attributes->{text};
					$parent = $parent->mother;
				} while( $parent );

				my $tags = join "::", map { my $tag = $_; $tag =~ s/ /_/g; $tag =~ s/'//g; $tag } @parent_text;
				my $card_text = $node->attributes->{text};
				my $first_page = $node->attributes->{page};

				push @$data, { page => $first_page, tag => $tags, text => $card_text };
			}

			return 1;
		}
	});

	my @page_to_heading;
	my $n_pages = $self->number_of_pages;
	for my $page (1..$n_pages) {
		my $heading_idx = 0;
		my $heading;
		while( $heading_idx + 1 < @$data && !( $page >= $data->[$heading_idx]{page} && $page < $data->[$heading_idx+1]{page} ) ) {
			$heading_idx++;
		}
		$heading = $data->[$heading_idx];

		$page_to_heading[$page] = $heading;
	}

	\@page_to_heading;
};

method get_page_text( $page_number ) {
	my ($stdout, $exit) = capture_stdout {
		system(
			PDFTOTEXT_PATH,
			qw(-f), $page_number,
			qw(-l), $page_number,
			qw(-enc UTF-8),
			"@{[ $self->filename ]}",
			qw(-)
		);
	};

	my $text = decode_utf8($stdout);

	return $text;
}

method get_page_header_text( $page_number ) {
	my $text = $self->get_page_text( $page_number ) // '';
	$text =~ s/^\s*$//gm;
	$text =~ s/[^\w\s]//gm;
	$text =~ s/^\n//gm;

	my ($line1, $line2) = split(/\n/, $text);
	my ($first_n_chars) = $text =~ /((?:\s*\S){20})/m;

	my $line_title = defined $line1 && defined $line2 ? "$line1 $line2" : undef;
	my $char_title = $first_n_chars;

	my $title = min_by { length $_ }
		grep { $_ !~ /^\s*$/ }
		map { s/\n|(^\s+)|(\s+$)//gr }
		grep { defined }
		($line_title, $char_title);

	return $title // '';
}

1;
