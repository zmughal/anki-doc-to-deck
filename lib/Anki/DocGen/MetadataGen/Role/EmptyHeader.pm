package Anki::DocGen::MetadataGen::Role::EmptyHeader;
# ABSTRACT: An empty header field

use Moo::Role;
use Function::Parameters;

method get_header(@) { '' }

1;
