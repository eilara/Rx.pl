package Reactive::Observable::SkipUntilObservable;

use Moose;

sub map_o1 { shift->o1->map(sub{ [1, $_] }) }
sub map_o2 { shift->o2->map(sub{ [2, $_] }) }

extends 'Reactive::Observable::DoubleWrapper';

package Reactive::Observable::SkipUntilObservable::Observer;

use Moose;

has is_skipping => (is => 'rw', default => 1);

extends 'Reactive::Observer::Wrapper';

sub on_next {
    my ($self, $notification) = @_;
    my ($child, $value) = @$notification;
    my $method = $child == 1? 'on_next_child': 'on_next_control';
    $self->$method($value);
}

sub on_next_child {
    my ($self, $value) = @_;
    return if $self->is_skipping;
    local $_ = $value;
    $self->wrap->on_next($value);
}

sub on_next_control {
    my ($self, $value) = @_;
    $self->is_skipping(0);
}

1;



