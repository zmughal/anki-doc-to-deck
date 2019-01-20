package Anki::DocGen::Process::Deck;
# ABSTRACT: Process deck

use Modern::Perl;
use Moo;
use Function::Parameters;
use Types::Path::Tiny qw(AbsPath);
use Path::Tiny;

use Safe::Isa;

use Text::CSV_XS qw(csv);
use Term::ProgressBar;

use Anki::DocGen::MetadataGen::Empty;

has media_directory => (
	is => 'ro',
	isa => AbsPath,
	coerce => 1,
	default => method() {
		Path::Tiny->tempdir;
	},
);

has metadata_generator => (
	is => 'ro',
	default => method() {
		Anki::DocGen::MetadataGen::Empty->new;
	}
);

has csv_filename => (
	is => 'ro',
	default => method() {
		Path::Tiny->tempfile;
	},
);

has _csv_data => (
	is => 'ro',
	default => method() { [] },
);

method write_csv() {
	csv(
		in => $self->_csv_data,
		out => $self->csv_filename->stringify,
		sep_char => ";",
		encoding => "UTF-8",
	);
}

method process( $doc_set ) {
	say "Generating cards for ", $doc_set->document->filename;

	my $progress_bar = Term::ProgressBar->new({
		name => $doc_set->document->basename,
		count => scalar @{ $doc_set->pages },
		remove => 0,
	});

	my $count = 0;
	for my $page (@{ $doc_set->pages }) {
		$self->add_note_for_page($doc_set, $page);
		$progress_bar->update(++$count);
	}
	say "\n";
}

method add_note_for_page($doc_set, $page_number) {
	push @{ $self->_csv_data },
		$self->generate_note_for_page($doc_set, $page_number);
}

method model_name() {
	...
}

method generate_note_for_page($doc_set, $page_number) {
	...
}

method filename_for_page($doc_set, $page_number) {
	my $filename =
		$doc_set->metadata_generator->$_call_if_can(
			get_media_filename =>
				$doc_set,
				$page_number )
		|| "@{[ $doc_set->document->basename ]} ${page_number}.png";

	$self->media_directory->child( $filename );
}

method render_page($doc_set, $page_number) {
	my $file = $self->filename_for_page($doc_set, $page_number);

	if( ! -f $file ) {
		$file->parent->mkpath;
		$file->spew_raw(
			$doc_set->document->get_rendered_png_data(
				page_number => $page_number,
				zoom_level => $doc_set->zoom_level
			)
		);
	}

	$file;
}


1;
