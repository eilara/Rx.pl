#!/usr/bin/perl

use v5.10;
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use Reactive;

Observable->once(3)
          ->subscribe(
                on_next     => sub { say "on_next=$_" },
                on_complete => sub { say "complete" },
            );
