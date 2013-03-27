#!/usr/bin/perl

use v5.10;
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use EV::Glib;
use Gtk3 '-init';
use Glib qw/TRUE FALSE/;
use Cairo;
use Reactive;
use Reactive::Observable::Gtk3; # for Gtk3 observables

my $window    = Gtk3::Window->new('toplevel');
my $area      = Gtk3::DrawingArea->new;
my $event_box = Gtk3::EventBox->new;
my $surface   = Cairo::ImageSurface->create ('argb32', 600, 400);
my $cairo     = Cairo::Context->create($surface);

$event_box ->add($area);
$window    ->add($event_box);

$window    ->set_position("mouse");
$window    ->set_default_size(600, 400);
$event_box ->set_events(2**8-1);
$cairo     ->set_source_rgb(1, 1, 1);
$cairo     ->paint;

$window    ->signal_connect(delete_event => sub { Reactive->unloop });
$area      ->signal_connect(draw         => \&draw );

$window->show_all;

my $button_press   = Observable->from_mouse_press($event_box)
                               ->map(sub{ 1 });
my $button_release = Observable->from_mouse_release($event_box)
                               ->map(sub{ 0 });

my $button_stream  = $button_press->merge($button_release)
                                  ->unshift(0);

my $motion_stream  = Observable->from_mouse_motion($event_box)
                               ->map(sub{ [$_->x, $_->y] })
                               ->unshift( [$window->get_pointer] );

my $sketch = $button_stream->combine_latest($motion_stream)
                           ->buffer(2, 1)
                           ->grep(sub{ $_->[1]->[0] })
                           ->map(sub{ [map { @{$_->[1]} } @$_]});


$sketch->subscribe(sub{
    my ($x0, $y0, $x1, $y1) = @{$_[0]};
    draw_line($x0, $y0, $x1, $y1);
});

Reactive->loop;

sub draw {
    my ($widget, $cr, $ref_status) = @_;
    $cr->set_source_surface($surface,0,0);
    $cr->paint;
    FALSE;
}

sub draw_line {
    my ($x1, $y1, $x2, $y2) = @_;
    $cairo->set_source_rgb(0, 0, 1);
    $cairo->set_line_width(6);
    $cairo->set_line_cap('round');
    $cairo->move_to($x1, $y1);
    $cairo->line_to($x2, $y2);
    $cairo->stroke;
    $area->queue_draw_area(0, 0, 640, 400);
}

