#!/usr/bin/perl

use v5.10;
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use Reactive;

my $o = Observable->interval(1000)
                  ->merge( Observable->interval(500) );

my $s = $o->subscribe(
    on_next     => sub { say "on_next=$_" },
    on_complete => sub { say "complete" },
);

say "Running event loop, hit enter to unsubscribe...";
Coro::Handle->new_from_fh(*STDIN)->readline;

$s = undef;

say "Hit enter to exit.";
Coro::Handle->new_from_fh(*STDIN)->readline;
