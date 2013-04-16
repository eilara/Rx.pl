#!/usr/bin/perl

use v5.10;
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use Curses;
use Reactive;

sub init    { initscr; noecho; cbreak; curs_set(0); refresh }
sub cleanup { endwin }
sub message { addstr 2, 4, 'Hit any key for echo, "x" to exit' }

init;
message;
refresh;

Observable->from_curses_stdin
          ->take_until(sub{ $_ eq 'x' })
          ->foreach(sub{ addstr 3, 5, "[$_]"; refresh });

cleanup;


