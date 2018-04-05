package Anki::DocGen::MetadataGen::Empty;
# ABSTRACT: An empty metadata generator

use Moo;
use Function::Parameters;

extends qw(Anki::DocGen::MetadataGen);

with qw(
	Anki::DocGen::MetadataGen::Role::EmptyHeader
	Anki::DocGen::MetadataGen::Role::EmptySources
	Anki::DocGen::MetadataGen::Role::EmptyTags
);

1;
