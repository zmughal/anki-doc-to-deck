package Anki::DocGen::MetadataGen::Role::PageTextRemarks;
# ABSTRACT: Remarks that contain the text of the page

use Moo::Role;
use Function::Parameters;
use HTML::Escape qw(escape_html);

method get_remarks( $doc_set, $page_number ) {
	join "\n",
		"<hr/>",
		"<h1>Page text</h1>",
		"<blockquote>",
		escape_html($doc_set->document->get_page_text( $page_number )),
		"</blockquote>";
}

1;
