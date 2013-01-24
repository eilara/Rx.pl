#!/usr/bin/perl

use v5.10;
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use Reactive;

Observable->range(10, 5)
          ->subscribe(
                on_next     => sub { say "on_next=$_" },
                on_complete => sub { say "complete" },
            );

