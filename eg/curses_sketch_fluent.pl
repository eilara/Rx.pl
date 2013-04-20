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

Observable->from_curses_stdin
          ->let(sub{
                my $stdin = $_;
                $stdin->grep(sub{ exists $move{$_} })
                      ->map(sub{ $move{$_} })
                      ->unshift([0,0])
                      ->scan([10,10], \&add_vectors)
                      ->combine_latest(
                            $stdin->grep(sub{ exists $brush{$_} })
                                  ->map(sub{ $brush{$_} })
                                  ->unshift('X')
                                  ->distinct_changes)
                      ->take_until( $stdin->grep(sub{ $_ eq 'q' }) );
            })->foreach(\&draw_pen);

cleanup;

__END__

 should be:

        foreach (from $stdin {
            take_until from $stdin { grep /q/ }
            combine_latest from $stdin {
                grep exists $move{$_}
                map $move{$_}
                unshift 'X'
                distinct_changes
            }
            scan [10,10], \&add_vectors
            unshift [0,0]
            map $move{$_}
            grep exists $move{$_}
        }) { &draw_pen }

