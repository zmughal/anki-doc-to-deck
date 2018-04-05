package Anki::DocGen::MetadataGen::Role::OutlineTags;
# ABSTRACT: Build tags based on PDF outline

use Moo::Role;
use Function::Parameters;

method get_tags($doc_proc, $page_number) {
	$doc_proc->document->_heading_data->[$page_number]->{tag};
}

1;
