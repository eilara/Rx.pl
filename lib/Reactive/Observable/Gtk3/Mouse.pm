package Reactive::Observable::Gtk3::Mouse;

use Moose;
use Glib qw/TRUE FALSE/;
use aliased 'Reactive::Disposable::Closure' => 'DisposableClosure';

has [qw(widget event)] => (is => 'ro', required => 1);

extends 'Reactive::Observable';

sub Event() { 'Reactive::Observable::Gtk3::Mouse::Event' }

sub run {
    my ($self, $observer) = @_;
    my $widget  = $self->widget;
    my $handler = sub { handle_event($observer, @_) };
    my $signal  = $widget->signal_connect($self->event, $handler );
    my $cleanup = sub { disconnect_handler($widget, $signal) };
    return DisposableClosure->new(cleanup => $cleanup);
}

sub disconnect_handler {
    my ($widget, $signal) = @_;
    $widget->signal_handler_disconnect($signal)
        if $widget->signal_handler_is_connected($signal);
}


sub handle_event {
    my ($observer, $widget, $event) = @_;
#    use Data::Dumper;print Dumper [@_];
    # sometimes Gtk sends here non-button events
    return FALSE if ref($event) eq 'Gtk3::Gdk::Event';
    my ($unknown, $ex, $ey, $state) = $event->window->get_pointer;
    $observer->on_next(Event->new($widget, $ex, $ey));
}

package Reactive::Observable::Gtk3::Mouse::Event;

use strict;
use warnings;

sub new {
    my $class = shift;
    return bless [@_], $class;
}

sub widget { shift->[0] }
sub x      { shift->[1] }
sub y      { shift->[2] }


1;

