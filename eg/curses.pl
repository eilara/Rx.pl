#!/usr/bin/perl

use v5.10;
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use Coro;
use Coro::EV;
use Curses;
use AnyEvent;
use AnyEvent::Handle;
use Reactive;
$|=1;

init();

#Observable->interval(400)->subscribe(sub{
#    addstr 10, 10, $_;
#    refresh;   
#});
my $hdl; $hdl = new AnyEvent::Handle
      fh => \*STDIN,
      on_read => sub {
          addstr 10,10, $hdl->{rbuf};
          $hdl->{rbuf} = '';
#          use Data::Dumper;say Dumper [@_];
          refresh;
      },

      on_error => sub {
         my ($hdl, $fatal, $msg) = @_;
         say "ERRPR:$msg";
         $hdl->destroy;
      };

Reactive->loop;

cleanup();

sub init {
    initscr;
    noecho;
    cbreak;
    curs_set(0);
    refresh;
}

sub cleanup {
    endwin;
}


