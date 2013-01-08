package Rx::Observer;

use strict;
use warnings;
use Moose;

has subs => (is => 'ro', required => 1);

sub on_next {
    my ($self, $value) = @_;
    local $_ = $value;
    $self->subs->{on_next}->($_);
}

sub on_complete { shift->subs->{on_complete}->() }

sub on_error {
    my ($self, $err) = @_;
    local $_ = $err;
    $self->subs->{on_error}->($_);
}

1;

