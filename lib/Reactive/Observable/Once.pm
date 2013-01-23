package Reactive::Observable::Once;

use strict;
use warnings;
use Moose;
use aliased 'Reactive::Disposable';

extends 'Reactive::Observable';

has value => (is => 'ro', required => 1);

sub run {
    my ($self, $observer) = @_;
    $observer->on_next($self->value);
    $observer->on_complete;
    return Disposable->empty;
}


1;

