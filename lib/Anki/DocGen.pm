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

=cut
