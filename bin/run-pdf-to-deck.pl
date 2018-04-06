#!/usr/bin/env perl
# PODNAME: run-pdf-to-deck
# ABSTRACT: Creates a CSV for a deck

use FindBin;
use lib "$FindBin::Bin/../lib";

use Modern::Perl;

use Anki::DocGen::Doc::PDF;
use Anki::DocGen::Doc::DOCX;

use Anki::DocGen::ApkgGen;
use Function::Parameters;
use Anki::DocGen::Process::Deck;
use Anki::DocGen::DocSet;

my @doc_sets = ();

fun add_document( $path ) {
	my $doc_class;

	if( $path =~ /\.pdf$/i ) {
		$doc_class = 'Anki::DocGen::Doc::PDF';
	} elsif( $path =~ /\.docx/i ) {
		$doc_class = 'Anki::DocGen::Doc::DOCX';
	} else {
		warn "Unsupported file: $path";
		return;
	}

	push @doc_sets, Anki::DocGen::DocSet->new(
		document => $doc_class->new( filename => $path ),
	);
}


fun main() {
	die "Need [pdfs...] [apkg]" if @ARGV < 2;

	while(@ARGV != 1) {
		add_document( shift @ARGV );
	}
	my $apkg_filename = shift @ARGV;

	my $doc_proc = Anki::DocGen::Process::Deck->new();

	my $apkg_gen = Anki::DocGen::ApkgGen->new(
		csv_filename => $doc_proc->csv_filename,
		media_directory => $doc_proc->media_directory,
		deck_name => 'My Deck',
		apkg_filename => $apkg_filename,
	);

	for my $doc_set (@doc_sets) {
		$doc_proc->process( $doc_set );
	}

	$doc_proc->write_csv;

	$apkg_gen->command([
		qw(schroot -c anki -- python), $apkg_gen->csv_to_apkg_script_path
	]);

	$apkg_gen->run;
}

main;
