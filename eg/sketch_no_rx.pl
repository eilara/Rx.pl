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

my ($last_x, $last_y, $is_pressed);

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

$window    ->signal_connect(delete_event         => sub { Reactive->unloop });
$area      ->signal_connect(draw                 => \&draw );
$event_box ->signal_connect(motion_notify_event  => \&mouse_move );
$event_box ->signal_connect(button_release_event => \&mouse_release );
$event_box ->signal_connect(button_press_event   => \&mouse_press );

$window->show_all;
Reactive->loop;

sub draw {
    my ($widget, $cr, $ref_status) = @_;
    $cr->set_source_surface($surface,0,0);
    $cr->paint;
    FALSE;
}

sub mouse_press {
    my ($da, $event) = @_;
    # sometimes Gtk sends here non-button events
    return FALSE unless $event->isa('Gtk3::Gdk::EventButton');
    my ($unknown, $ex, $ey, $state) = $event->window->get_pointer;
    draw_line($ex, $ey, $ex, $ey);
    ($last_x, $last_y) = ($ex, $ey);
    $is_pressed = 1;
    FALSE;
}

sub mouse_release {
    my ($da, $event) = @_;
    $is_pressed = 0;    
    FALSE;
}

sub mouse_move {
    my ($da, $event) = @_;
    my ($unknown, $ex, $ey, $state) = $event->window->get_pointer;
    return FALSE unless $is_pressed;
    draw_line($last_x, $last_y, $ex, $ey);
    ($last_x, $last_y) = ($ex, $ey);
    FALSE;
}

sub draw_line {
    my ($x1, $y1, $x2, $y2) = @_;
    $cairo->set_source_rgb(0, 0, 1);
    $cairo->set_line_width(6);
    $cairo->set_line_cap('round');
    $cairo->set_line_join('round');
    $cairo->move_to($x1, $y1);
    $cairo->line_to($x2, $y2);
    $cairo->stroke;
    $area->queue_draw_area(0, 0, 640, 400);
}

