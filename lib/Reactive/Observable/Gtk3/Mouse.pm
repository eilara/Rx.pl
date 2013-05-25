package Reactive::Observable::Gtk3::Mouse;

use Moose;
use Glib qw/TRUE FALSE/;
use aliased 'Reactive::Disposable::Closure' => 'DisposableClosure';

has [qw(widget event)] => (is => 'ro', required => 1);

extends 'Reactive::Observable';

sub _Event() { 'Reactive::Observable::Gtk3::Mouse::Event' }

=head1 METHODS

=head2 $class->new( widget => $widget, event => $event)

Construct a new class from widget $widget and event $event.

=head2 $self->run($observer)

Attach to the $observer.

=head2 TRUE

Imported from Gtk+ . B<Ignore> .

=head2 FALSE

Imported from Gtk+ . B<Ignore> .

=cut

sub run {
    my ($self, $observer) = @_;
    my $widget  = $self->widget;
    my $handler = sub { _handle_event($observer, @_) };
    my $signal  = $widget->signal_connect($self->event, $handler );
    my $cleanup = sub { _disconnect_handler($widget, $signal) };
    return DisposableClosure->new(cleanup => $cleanup);
}

sub _disconnect_handler {
    my ($widget, $signal) = @_;
    $widget->signal_handler_disconnect($signal)
        if $widget->signal_handler_is_connected($signal);
}


sub _handle_event {
    my ($observer, $widget, $event) = @_;
    # sometimes Gtk sends here non-button events
    return FALSE if ref($event) eq 'Gtk3::Gdk::Event';
    my ($unknown, $ex, $ey, $state) = $event->window->get_pointer;
    $observer->on_next(_Event->new($widget, $ex, $ey));
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

