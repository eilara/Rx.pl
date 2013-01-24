package Reactive::Disposable::Wrapper;

use Moose;

has wrap => (is => 'rw');

extends 'Reactive::Disposable';

before dispose => sub { shift->{wrap} = undef };

# TODO should we call dispose on wrap, when we dispose?

1;

