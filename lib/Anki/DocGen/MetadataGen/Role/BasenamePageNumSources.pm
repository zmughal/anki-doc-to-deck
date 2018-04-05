package Anki::DocGen::MetadataGen::Role::BasenamePageNumSources;
# ABSTRACT: Metadata the is the basename and page number

use Moo::Role;
use Function::Parameters;

method get_sources($doc_proc, $page_number) {
	my $padding = length $doc_proc->document->number_of_pages;
	return sprintf(
		"%s %0${padding}d",
		$doc_proc->document->basename,
		$page_number
	);
}

1;
