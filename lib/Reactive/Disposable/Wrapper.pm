package Reactive::Disposable::Wrapper;

use strict;
use warnings;
use Moose;

has wrap => (is => 'rw');

extends 'Reactive::Disposable';

before dispose => sub { shift->{wrap} = undef };

1;

