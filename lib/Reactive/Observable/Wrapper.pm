package Reactive::Observable::Wrapper;

use Moose;

has wrap => (is => 'rw', required => 1);

extends 'Reactive::Observable::Composite';

augment observer_args => sub {
    my ($self, $observer) = @_;
    return (wrap => $observer, inner(@_));
};

1;

