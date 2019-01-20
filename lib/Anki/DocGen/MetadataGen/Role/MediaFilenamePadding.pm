package Anki::DocGen::MetadataGen::Role::MediaFilenamePadding;
# ABSTRACT: Use padding for media filename

use Moo::Role;
use Function::Parameters;

method get_media_filename($doc_set, $page_number) {
	my $padding = length $doc_set->document->number_of_pages;
	return sprintf(
		"%s %0${padding}d.png",
		$doc_set->document->basename,
		$page_number
	);
}

1;
