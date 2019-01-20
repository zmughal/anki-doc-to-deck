package Anki::DocGen::Command::DocToDeck;
# ABSTRACT: Converts documents to a deck

use Moo;
use CLI::Osprey;

use Anki::DocGen::ApkgGen;
use Function::Parameters;
use Anki::DocGen::Process::Deck;

use Anki::DocGen::Process::Deck::ImageOcclusionEnhanced;

use Anki::DocGen::DocSet;
use Anki::DocGen::DocFactory::ByPath;

option deck_name => (
	is => 'ro',
	format => 's',
	required => 0,
	doc => 'Name of the deck to create (default: My Deck)',
	default => 'My Deck',
);

my @doc_sets = ();

method add_document( $path ) {
	push @doc_sets, Anki::DocGen::DocSet->new(
		document => Anki::DocGen::DocFactory::ByPath->new(
				filename => $path
			)->get_doc,
	);
}

method run() {
	die "Need [PDF and DOCX files...] [apkg file]" if @ARGV < 2;

	while(@ARGV != 1) {
		$self->add_document( shift @ARGV );
	}
	my $apkg_filename = shift @ARGV;

	my $processor_class = 'Anki::DocGen::Process::Deck::ImageOcclusionEnhanced';

	my $doc_proc = $processor_class->new();

	my $apkg_gen = Anki::DocGen::ApkgGen->new(
		csv_filename => $doc_proc->csv_filename,
		media_directory => $doc_proc->media_directory,
		deck_name => $self->deck_name,
		apkg_filename => $apkg_filename,
		model_name => $doc_proc->model_name,
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

1;
