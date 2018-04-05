package Anki::DocGen::Doc::PDF;
# ABSTRACT: A PDF document

use Modern::Perl;
use Mu;
use Function::Parameters;

use Renard::Incunabula::Format::PDF::Document;

extends qw(Anki::DocGen::Doc);

lazy basename => method() {
	$self->filename->basename(qw(.pdf));
};

lazy _renard_doc =>
	method() {
		Renard::Incunabula::Format::PDF::Document->new(
			filename => $self->filename
		);
	},
	(
		handles => [ qw(number_of_pages) ],
	);

method get_rendered_png_data(@) {
	$self->_renard_doc->get_rendered_page( @_ )->png_data;
}

1;
