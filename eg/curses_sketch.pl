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

__END__

 should be with less arrows toe nail clippings and subs, maybe like this,
 though it be wrong in many ways:

      my @stdin = Observable->from_curses_stdin;
      my @quit  = grep { /q/ } @stdin;
      my @brush = uniq { $a eq $b } 
                  unshift 'X'
                  map { $brush{$_} }
                  grep {exists $brush{$_} }
                  @stdin;
      my @xy    = take_until $quit
                  combine_latest $brush
                  scan [[10,10], \&add_vectors]
                  unshift [0,0]
                  map { $move{$_} }
                  grep { exists $move{$_}
                  @stdin;

      draw_pen($_) foreach @xy;                  
