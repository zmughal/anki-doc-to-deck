package Anki::DocGen::MetadataGen::Role::EmptyTags;
# ABSTRACT: An empty tags field

use Moo::Role;
use Function::Parameters;

method get_tags(@) { '' }

1;
