package Anki::DocGen::Doc;
# ABSTRACT: A document file on disk

use Moo;
use Function::Parameters;
use Types::Path::Tiny qw(AbsFile);

has filename => (
	is => 'ro',
	isa => AbsFile,
	coerce => 1,
);

method get_rendered_png_data(@) {
	...
}

method number_of_pages() {
	...
}

method basename() {
	...
}

1;
