package Anki::DocGen::MetadataGen::Role::OutlineHeader;
# ABSTRACT: Get header from outline

use Moo::Role;
use Function::Parameters;

method get_header($doc_proc, $page_number) {
	"" . $doc_proc->document->_heading_data->[$page_number]->{text};
}

1;
