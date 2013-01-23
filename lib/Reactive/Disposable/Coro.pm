package Reactive::Disposable::Coro;

use strict;
use warnings;
use Moose;

has coro => (is => 'rw', required => 1);

extends 'Reactive::Disposable';

before dispose => sub {
    my $self = shift;
    next unless $self->coro;
    $self->coro->cancel;
    $self->coro(undef);
};

1;

__END__
