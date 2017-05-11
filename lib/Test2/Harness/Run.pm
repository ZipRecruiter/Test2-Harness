package Test2::Harness::Run;
use strict;
use warnings;

use Carp qw/croak/;

use Test2::Util qw/IS_WIN32/;

use Test2::Harness::Util::HashBase qw{
    -run_id

    -job_count
    -switches
    -libs -lib -blib
    -preload
    -args
    -input

    -chdir
    -search
    -unsafe_inc

    -env_vars
};

sub init {
    my $self = shift;

    # Put this here, before loading data, loaded data means a replay without
    # actually running tests, this way we only die if we are starting a new run
    # on windows.
    croak "preload is not supported on windows"
        if IS_WIN32 && $self->{+PRELOAD};

    croak "The 'run_id' attribute is required"
        unless $self->{+RUN_ID};

    $self->{+CHDIR}     ||= undef;
    $self->{+SEARCH}    ||= ['t'];
    $self->{+PRELOAD}   ||= undef;
    $self->{+SWITCHES}  ||= [];
    $self->{+ARGS}      ||= [];
    $self->{+LIBS}      ||= [];
    $self->{+LIB}       ||= 0;
    $self->{+BLIB}      ||= 0;
    $self->{+JOB_COUNT} ||= 1;
    $self->{+INPUT}     ||= undef;

    $self->{+UNSAFE_INC} = 1 unless defined $self->{+UNSAFE_INC};

    my $env = $self->{+ENV_VARS} ||= {};
    $env->{PERL_USE_UNSAFE_INC} = $self->{+UNSAFE_INC} unless defined $env->{PERL_USE_UNSAFE_INC};

    $env->{T2_HARNESS_RUN_ID}  = $self->{+RUN_ID};
    $env->{T2_HARNESS_JOBS}    = $self->{+JOB_COUNT};
    $env->{HARNESS_JOBS}       = $self->{+JOB_COUNT};
}

sub all_libs {
    my $self = shift;

    my @libs;

    push @libs => 'lib' if $self->{+LIB};
    push @libs => 'blib/lib', 'blib/arch' if $self->{+BLIB};
    push @libs => @{$self->{+LIBS}} if $self->{+LIBS};

    return @libs;
}

sub TO_JSON { return { %{$_[0]} } }

sub find_files {
    my $self = shift;

    my $search = $self->search;

    my (@files, @dirs);

    for my $item (@$search) {
        push @files => $item and next if -f $item;
        push @dirs  => $item and next if -d $item;
        die "'$item' does not appear to be either a file or a directory.\n";
    }

    require File::Find;
    File::Find::find(
        sub {
            no warnings 'once';
            return unless -f $_ && m/\.t2?$/;
            push @files => $File::Find::name;
        },
        @dirs
    );

    return sort @files;
}


1;