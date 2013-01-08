#!/usr/bin/perl

use v5.10;
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use Rx;

my $o = Rx->range(10, 5);

my $s = $o->subscribe(
    on_next     => sub { say "on_next=$_" },
    on_complete => sub { say "complete" },
);

say "Running event loop...";
Rx->run;
