package Reactive::Observable::Defer;

use Moose;

extends 'Reactive::Observable';

has projection => (is => 'ro', required => 1);

sub run {
    my ($self, $observer) = @_;
    my $observable = $self->projection->();
    return $observable->subscribe_observer($observer);
}


1;

