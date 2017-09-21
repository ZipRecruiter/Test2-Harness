package Test2::Harness::Util::Debug;
use strict;
use warnings;

our $VERSION = '0.001016';

use Importer Importer => 'import';

our @EXPORT = qw/DEBUG/;
our @EXPORT_OK = qw/DEBUG DEBUG_ON DEBUG_OFF/;

my $DEBUG = $ENV{T2_HARNESS_DEBUG};

sub DEBUG_ON  { $DEBUG = 1 }
sub DEBUG_OFF { $DEBUG = 0 }

sub DEBUG {
    return unless $DEBUG;
    chomp($_[-1]);
    print STDERR @_, "\n";
}

$SIG{USR1} = sub {
    $DEBUG = !$DEBUG;
    print STDERR "SIGUSR1 Detected, turning on debugging...\n";
};

1;
