package Anki::DocGen::MetadataGen::Role::BasenamePageNumSources;
# ABSTRACT: Metadata the is the basename and page number

use Moo::Role;
use Function::Parameters;

method get_sources($doc_set, $page_number) {
	my $padding = length $doc_set->document->number_of_pages;
	return sprintf(
		"%s %0${padding}d",
		$doc_set->document->basename,
		$page_number
	);
}

1;
