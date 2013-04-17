#!/usr/bin/perl

use v5.10;
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use Curses;
use Reactive;

sub init    { initscr; noecho; cbreak; curs_set(0) }
sub cleanup { endwin }

init;
addstr 2, 4, 'Hit any key for echo, "q" to quit';
refresh;

Observable->from_curses_stdin
          ->take_until(sub{ $_ eq 'q' })
          ->foreach(sub{ addstr 3, 5, "[$_]"; refresh });

cleanup;


