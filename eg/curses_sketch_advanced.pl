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

sub init        { initscr; noecho; cbreak; curs_set(1) }
sub cleanup     { endwin }
sub add_vectors { [$_[0]->[0] + $_[1]->[0], $_[0]->[1] + $_[1]->[1]] }

sub move_cursor {
    my $yx = shift;
    setsyx @$yx;
    doupdate;
}

sub draw_pen { 
    my ($yx, $brush) = @{shift()};
    addstr @$yx, $brush;
    refresh;
    move_cursor($yx);
}

init;
addstr 2, 4, 'Hit space to toggle draw, "wasd" to move, "12" '.
             'to change brush, "q" to quit';
refresh;

my $stdin = Observable->from_curses_stdin;

my $quit = $stdin->grep(sub{ /q/ });

my $brush = $stdin->grep(sub{ exists $brush{$_} })
                  ->map(sub{ $brush{$_} })
                  ->unshift('X')
                  ->distinct_changes;

my $toggle = $stdin->grep(sub{ / / })
                   ->scan(0, sub{ !$_[0] });

my $xy = $stdin->grep(sub{ exists $move{$_} })
               ->map(sub{ $move{$_} })
               ->unshift([0,0])
               ->scan([10,10], \&add_vectors);

my $cursor = $xy->take_until($quit)
                ->subscribe(\&move_cursor);

$xy->publish->connect
   ->combine_latest($brush)
   ->skip_until( $toggle->grep(sub{  $_ }) )
   ->take_until( $toggle->grep(sub{ !$_ }) )
   ->repeat
   ->take_until($quit)
   ->foreach(\&draw_pen);

cleanup;

__END__

TODO
    - change cursor style dependeing on drawing mode
    - status bar shows x,y and brush and mode
    - continuous drawing vs. pixel drawing
    - mouse support
