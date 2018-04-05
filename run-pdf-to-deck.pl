#!/usr/bin/env perl
# PODNAME: run-pdf-to-deck
# ABSTRACT: Creates a CSV for a deck

use FindBin;
use lib "$FindBin::Bin/lib";

use Modern::Perl;
use Anki::DocGen::Doc::PDF;
use Anki::DocGen::ApkgGen;
use Function::Parameters;

package DocProcess {
	use Moo;
	use Function::Parameters;
	use Types::Path::Tiny qw(AbsPath);
	use Path::Tiny;

	use Image::Size;
	use SVG;
	use UUID::Tiny ':std';
	use Text::CSV_XS qw(csv);

	use Anki::DocGen::MetadataGen::Empty;

	has document => ( is => 'ro', required => 1 );

	has zoom_level => ( is => 'ro', default => 1.5 );

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
			sep_char => ";"
		);
	}

	method add_note_for_page($page_number) {
		push @{ $self->_csv_data },
			$self->generate_note_for_page($page_number);
	}

	method generate_note_for_page($page_number) {
		my @fields = qw( id header image qmask footer remarks sources extra1 extra2 amask omask );

		my %note;

		my $uuid = create_uuid_as_string(UUID_V4);

		my $uniq_id =  $uuid =~ s/-//gr;
		my $occl_tp = 'oa';
		my $note_nr = '1';

		my $occl_id = join( '-' , $uniq_id, $occl_tp);
		my $note_id = join( '-' , $uniq_id, $occl_tp, $note_nr);

		# Make media: page image and Q,A,O masks
		my $image_file = $self->render_page($page_number);

		my $qmask_file = $self->media_directory->child("${note_id}-Q.svg");
		$qmask_file->spew_utf8( $self->get_mask_svg( $image_file, $note_id, 'Q') );

		my $amask_file = $self->media_directory->child("${note_id}-A.svg");
		$amask_file->spew_utf8( $self->get_mask_svg( $image_file, $note_id, 'A') );

		my $omask_file = $self->media_directory->child("${occl_id}-O.svg");
		$omask_file->spew_utf8( $self->get_mask_svg( $image_file, $note_id, 'O') );

		$note{id} = $note_id;
		$note{header} = $self->metadata_generator->get_header($self, $page_number);
		$note{image} = qq|<img src="@{[ $image_file->basename ]}"/>|;
		$note{qmask} = qq|<img src="@{[ $qmask_file->basename ]}" />|;
		$note{footer} = '';
		$note{remarks} = '';
		$note{sources} = $self->metadata_generator->get_sources($self, $page_number);
		$note{extra1} = '';
		$note{extra2} = '';
		$note{amask} = qq|<img src="@{[ $amask_file->basename ]}" />|;
		$note{omask} = qq|<img src="@{[ $omask_file->basename ]}" />|;
		$note{tags} = $self->metadata_generator->get_tags($self, $page_number);


		return [ @note{ @fields, qw(tags) } ];
	}

	method filename_for_page($page_number) {
		my $filename =
			$self->metadata_generator->can( 'get_media_filename')
			? $self->metadata_generator->get_media_filename(
				$self,
				$page_number )
			: "@{[ $self->document->basename ]} ${page_number}.png";

		$self->media_directory->child( $filename );
	}

	method render_page($page_number) {
		my $file = $self->filename_for_page($page_number);

		if( ! -f $file ) {
			$file->parent->mkpath;
			$file->spew_raw(
				$self->document->get_rendered_png_data(
					page_number => $page_number,
					zoom_level => $self->zoom_level
				)
			);
		}

		$file;
	}

	method get_svg($image_file) {
		my ($width, $height) = imgsize("$image_file");

		my $svg = SVG->new(
			width => $width,
			height => $height,
			-nocredits  => 1,
		);

		$svg->comment( 'Created with Image Occlusion Enhanced' );
		my $label_group = $svg->group();
		$label_group->title->cdata('Labels');
		my $mask_group = $svg->group();
		$mask_group->title->cdata('Masks');

		return +{
			svg    => $svg,
			labels => $label_group,
			masks  => $mask_group,
			width  => $width,
			height => $height,
		};
	}

	method get_mask_svg($image_file, $note_id, $type) {
		my $svg_data = $self->get_svg($image_file);

		my $attr_by_mask_type = {
			O => {
				fill   => "#FFEBA2",
				stroke => "#2D2D2D",
			},
			A => {},
			Q => {
				class  => "qshape",
				fill   => "#FF7E7E",
				stroke => "#2D2D2D",
			},
		};

		if( $type eq 'Q' || $type eq 'O' ) {
			$svg_data->{masks}->rect(
				x      => 0.95  * $svg_data->{width},
				y      => 0.95  * $svg_data->{height},
				width  => 0.025 * $svg_data->{width},
				height => 0.025 * $svg_data->{height},
				id => $note_id,
				%{ $attr_by_mask_type->{$type} }
			);
		}

		$svg_data->{svg}->xmlify;
	}
};

sub main {
	die "Need [pdf] [apkg]" if @ARGV != 2;

	my $pdf_filename = $ARGV[0];
	my $apkg_filename = $ARGV[1];

	my $doc = Anki::DocGen::Doc::PDF->new( filename => $pdf_filename );

	my $metadata_class = Role::Tiny->create_class_with_roles(
		'Anki::DocGen::MetadataGen',
		qw(
			Anki::DocGen::MetadataGen::Role::CopyFromSourcesFieldHeader
			Anki::DocGen::MetadataGen::Role::BasenamePageNumSources
			Anki::DocGen::MetadataGen::Role::EmptyTags
		),
	);

	my $doc_proc = DocProcess->new(
		document => $doc,
		metadata_generator => $metadata_class->new,
	);

	my $apkg_gen = Anki::DocGen::ApkgGen->new(
		csv_filename => $doc_proc->csv_filename,
		media_directory => $doc_proc->media_directory,
		deck_name => $doc_proc->document->basename,
		apkg_filename => $apkg_filename,
	);

	my $n_pages = $doc->number_of_pages;
	for my $page (1..$n_pages) {
		say $page;
		$doc_proc->add_note_for_page($page);
	}
	$doc_proc->write_csv;

	$apkg_gen->command([
		qw(schroot -c anki -- python), $apkg_gen->csv_to_apkg_script_path
	]);

	$apkg_gen->run;
}

main;
