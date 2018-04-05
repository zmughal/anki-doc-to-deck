#!/usr/bin/env perl
# PODNAME: run-pdf-to-deck
# ABSTRACT: Creates a CSV for a deck

use FindBin;
use lib "$FindBin::Bin/lib";

use Modern::Perl;
use Anki::DocGen::Doc::PDF;
use Anki::DocGen::ApkgGen;
use Function::Parameters;
use Anki::DocGen::Process::Deck;

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

	my $doc_proc = Anki::DocGen::Process::Deck->new(
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
