#!/usr/bin/perl

use v5.10;
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use Curses;
use Reactive;

my %move  = (w => [-1,0], s => [1,0], a => [0,-1], d => [0,1]);
my %brush = (1 => 'X', 2 => 'O');

sub init        { initscr; noecho; cbreak; curs_set(0) }
sub cleanup     { endwin }
sub add_vectors { [$_[0]->[0] + $_[1]->[0], $_[0]->[1] + $_[1]->[1]] }

sub draw_pen { 
    my ($xy, $brush) = @{shift()};
    addstr @$xy, $brush;
    refresh;
}

init;
addstr 2, 4, 'Hit "wasd" to move, "12" to change brush, "q" to quit';
refresh;

my $stdin = Observable->from_curses_stdin;
my $quit  = $stdin->grep(sub{ $_ eq 'q' });
my $brush = $stdin->grep(sub{ exists $brush{$_} })
                  ->map(sub{ $brush{$_} })
                  ->unshift('X')
                  ->distinct_changes;

$stdin->grep(sub{ exists $move{$_} }) # only move
      ->map(sub{ $move{$_} })         # we want delta not key pressed
      ->unshift([0,0])                # draw 1st point on start
      ->scan([10,10], \&add_vectors)  # keep and update position
      ->combine_latest($brush)        # combine with latest brush selection
      ->take_until($quit)             # exit on quit
      ->foreach(\&draw_pen);

cleanup;
