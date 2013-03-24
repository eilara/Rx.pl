package Reactive::Observable::Wrapper;

use Moose;

has wrap => (is => 'rw', required => 1);

extends 'Reactive::Observable::Composite';

sub observer_args {
    my ($self, $observer, $disposable_wrapper) = @_;
    return (wrap => $observer);
}

1;

