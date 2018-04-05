package Anki::DocGen::MetadataGen::Role::EmptySources;
# ABSTRACT: An empty source field

use Moo::Role;
use Function::Parameters;

method get_sources(@) { '' }

1;
