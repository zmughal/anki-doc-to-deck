package Anki::DocGen;
# ABSTRACT: Generate Anki decks for Image Occlusion Enhanced using pages from documents

use strict;
use warnings;

1;

=head1 SYNOPSIS

  run-pdf-to-deck.pl [PDF or DOCX files...] Deck.apkg

=head1 DESCRIPTION

Generates an Anki deck that can be edited using L<Image Occlusion
Enhanced|https://github.com/glutanimate/image-occlusion-enhanced> by
extracting all the pages from the given documents. The fields/tags for each
card are configurable by using a subclass of C<Anki::DocGen::MetadataGen>.

Note that once you import the Anki .apkg deck, if you want to edit them using
the Image Occlusion Editor, then you need to go to the card browser and select
all the cards with the imported note type (e.g., C<Image Occlusion
Enhanced-312b0>) and use C<< Edit -> Change Note Type... >> to set the note
type to C<Image Occlusion Enhanced>.

=head1 EXAMPLE

Cards made using L<Lecture 20 Lab-on-a-Chip.pdf|http://www-bsac.eecs.berkeley.edu/projects/ee245/Lectures/lecturepdfs/Lecture%2020%20Lab-on-a-Chip.pdf>

=begin html

<img src="https://raw.githubusercontent.com/zmughal/anki-doc-to-cards/master/doc/example.png" />

=end html

=cut
