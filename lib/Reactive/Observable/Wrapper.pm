package Reactive::Observable::Wrapper;

use Moose;

has wrap => (is => 'rw', required => 1);

extends 'Reactive::Observable::Composite';

sub initial_subscriptions { (shift->wrap) }

1;

