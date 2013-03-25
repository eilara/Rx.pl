#!/usr/bin/perl

use v5.10;
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use Reactive;

my $s1 = Observable->from_stdin->subscribe(
    on_next     => sub { say "on_next  1=$_" },
    on_error    => sub { say "on_error 1=$_" },
    on_complete => sub { say "complete 1" },
);

my $s2 = Observable->from_stdin->subscribe(
    on_next     => sub { say "on_next  2=$_" },
    on_error    => sub { say "on_error 2=$_" },
    on_complete => sub { say "complete 2" },
);

say "Running event loop, hit ctrl-d to restart...";
Reactive::loop;

my $s3 = Observable->from_stdin->subscribe(
    on_next     => sub { say "on_next  3=$_" },
    on_error    => sub { say "on_error 3=$_" },
    on_complete => sub { say "complete 3" },
);

say "Running event loop, hit ctrl-d to exit...";
Reactive::loop;

