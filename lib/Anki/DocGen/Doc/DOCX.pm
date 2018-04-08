package Anki::DocGen::Doc::DOCX;
# ABSTRACT: An OOXML .docx document

use Modern::Perl;
use Mu;
use Function::Parameters;
use Path::Tiny;
use File::Which;

use Anki::DocGen::Doc::PDF;

extends qw(Anki::DocGen::Doc);

use constant UNOCONV_COMMAND => 'unoconv';

BEGIN {
	which(UNOCONV_COMMAND) or die "Can not find unoconv converter";
}

lazy basename => method() {
	$self->filename->basename(qw(.docx .doc .pptx .ppt));
};

lazy _pdf_doc =>
	method() {
		$self->convert_to_pdf;
		Anki::DocGen::Doc::PDF->new(
			filename => $self->_temp_pdf_filename,
		);
	},
	(
		handles => [ qw(
			number_of_pages get_rendered_png_data
			get_page_text get_page_header_text
		)],
	);

lazy _temp_pdf_filename => method() {
	Path::Tiny->tempfile( SUFFIX => '.pdf' );
};

method convert_to_pdf() {
	system(
		UNOCONV_COMMAND,
		qw(--format pdf),
		qw(--output), $self->_temp_pdf_filename,

		$self->filename,
	) == 0 or die "Could not convert with unoconv: @{[ $self->filename ]}";
}

1;
