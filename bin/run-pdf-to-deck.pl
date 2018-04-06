#!/usr/bin/env perl
# PODNAME: run-pdf-to-deck
# ABSTRACT: Creates a CSV for a deck

use FindBin;
use lib "$FindBin::Bin/../lib";

use Modern::Perl;
use Anki::DocGen::Command::DocToDeck;

Anki::DocGen::Command::DocToDeck->new_with_options->run;
