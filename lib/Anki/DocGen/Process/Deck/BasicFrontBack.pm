package Anki::DocGen::Process::Deck::BasicFrontBack;
# ABSTRACT: Deck processor for Basic front-back cards

use Modern::Perl;
use Moo;
use Function::Parameters;

use Safe::Isa;

extends qw(Anki::DocGen::Process::Deck);

method model_name() {
	'Basic';
}

method generate_note_for_page($doc_set, $page_number) {
	return if $page_number % 2 == 0;

	my @fields = qw( front back );

	my %note;

	my @metadata_args = ( $doc_set, $page_number );

	# Make media: page image (odd, even)
	my $front_image_file = $self->render_page($doc_set, $page_number    );
	my $back_image_file  = $self->render_page($doc_set, $page_number + 1);


	$note{front}   = qq|<img src="@{[ $front_image_file->basename ]}"/>|;
	$note{back}    = qq|<img src="@{[ $back_image_file->basename ]}" />|;
	$note{tags}    = $doc_set->metadata_generator->$_call_if_can( get_tags    => @metadata_args ) || '';

	return [ @note{ @fields, qw(tags) } ];
}

1;
