package Anki::DocGen::ApkgGen;
# ABSTRACT: Generate an apkg from CSV + media

use Modern::Perl;
use Mu;
use Function::Parameters;
use Types::Path::Tiny qw(AbsPath AbsDir AbsFile);
use Types::Standard qw(StrMatch ArrayRef);
use Path::Tiny;

lazy csv_to_apkg_script_path => method() {
	my $module_dir = path(__FILE__)->parent;
	$module_dir->child(qw(ApkgGen csv-to-apkg.py));
};

has command => (
	is => 'rw',
	isa => ArrayRef,
	default => method() {
		[ qw(python), $self->csv_to_apkg_script_path ]
	},
);

has csv_filename => (
	is => 'ro',
	required => 1,
	isa => AbsFile,
	coerce => 1
);

has apkg_filename => (
	is => 'ro',
	required => 1,
	isa => AbsPath,
	coerce => 1
);

has media_directory => (
	is => 'ro',
	required => 1,
	isa => AbsDir,
	coerce => 1
);

has deck_name => (
	is => 'ro',
	required => 1,
	isa => StrMatch[qr/./],
	required => 1,
);

has model_name => (
	is => 'ro',
	isa => StrMatch[qr/./],
	required => 1,
);

method BUILD(@) {
	die "apkg_filename must end in .apkg" unless $self->apkg_filename =~ /\.apkg$/;
}

method run() {
	system(
		@{ $self->command },

		qw(--csv-filename)   , $self->csv_filename,
		qw(--deck-name)      , $self->deck_name,
		qw(--apkg-filename)  , $self->apkg_filename,
		qw(--media-directory), $self->media_directory,
		qw(--model-name)     , $self->model_name,
	)
}

1;
