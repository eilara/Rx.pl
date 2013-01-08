#!/usr/bin/perl

use v5.10;
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use Rx;

my $o = Rx->from_stdin
          ->map(sub { eval "$_" });

my $s = $o->subscribe(
    on_next     => sub { say "on_next=$_" },
    on_error    => sub { say "on_error=$_" },
    on_complete => sub { say "complete" },
);

say "Running event loop, hit ctrl-c to exit...";
Rx->run;
