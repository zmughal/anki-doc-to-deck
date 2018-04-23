package Anki::DocGen::DocSet;
# ABSTRACT: A set of options to use to process a document

use Moo;
use Function::Parameters;

has document => (
	is => 'ro',
	required => 1,
);

has zoom_level => ( is => 'ro', default => 1.5 );

has pages => (
	is => 'ro',
	default => method() { [ 1..$self->document->number_of_pages ] },
);

has metadata_generator => (
	is => 'ro',
	default => method() {
		my $metadata_class = Role::Tiny->create_class_with_roles(
			'Anki::DocGen::MetadataGen',
			qw(
				Anki::DocGen::MetadataGen::Role::CopyFromSourcesFieldHeader
				Anki::DocGen::MetadataGen::Role::BasenamePageNumSources
				Anki::DocGen::MetadataGen::Role::EmptyTags
				Anki::DocGen::MetadataGen::Role::PageTextRemarks
			),
		);

		my $metadata_generator = $metadata_class->new;
	},
);

1;
