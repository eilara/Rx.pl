package Reactive::Disposable::Timer;

use strict;
use warnings;
use Moose;

has timer => (is => 'rw');

extends 'Reactive::Disposable';

before dispose => sub { shift->{timer} = undef };

1;

__END__
