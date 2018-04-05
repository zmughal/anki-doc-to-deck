package Anki::DocGen::MetadataGen::Role::CopyFromSourcesFieldHeader;
# ABSTRACT: Metadata for header is the same as the Sources field

use Moo::Role;
use Function::Parameters;

method get_header(@) { $self->get_sources(@_) }

1;
