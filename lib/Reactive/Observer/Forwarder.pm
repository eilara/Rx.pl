package Reactive::Observer::Forwarder;

use strict;
use warnings;
use Moose;

has target => (is => 'ro', required => 1);
has parent => (is => 'ro', required => 1, weak_ref => 1);

sub on_next {
    my ($self, $value) = @_;
    local $_ = $value;
    $self->target->on_next($value);
}

sub on_complete {
    my $self = shift;
    $self->target->on_complete();
    $self->dispose;
}

sub on_error {
    my ($self, $err) = @_;
    local $_ = $err;
    $self->target->on_error($_);
    $self->dispose;
}

sub dispose {
    my $self = shift;
    $self->{target} = undef;
    $self->{parent} = undef;
}

1;

