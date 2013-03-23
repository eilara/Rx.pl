package Reactive::Observable::FromClosure;

use Moose;

extends 'Reactive::Observable';

has on_subscribe => (is => 'ro', required => 1);

sub run {
    my ($self, $observer) = @_;
    return $self->on_subscribe->($observer);
}


1;

