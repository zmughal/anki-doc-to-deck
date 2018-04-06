package Anki::DocGen::DocFactory::ByPath;
# ABSTRACT: Returns the document class appropriate for a given class

use Moo;
use Function::Parameters;

has filename => (
	is => 'ro',
	required => 1,
);

method get_doc() {
	$self->get_doc_class->new(
		filename => $self->filename
	);
}

method get_doc_class() {
	my $path = $self->filename;

	my $doc_class;

	if( $path =~ /\.pdf$/i ) {
		$doc_class = 'Anki::DocGen::Doc::PDF';
	} elsif( $path =~ /\.docx/i ) {
		$doc_class = 'Anki::DocGen::Doc::DOCX';
	} else {
		warn "Unsupported file: $path";
		return;
	}

	return $doc_class;
}

1;
