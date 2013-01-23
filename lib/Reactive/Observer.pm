package Reactive::Observer;

use strict;
use warnings;
use Moose;

has handlers => (is => 'ro', required => 1);

sub on_next {
    my ($self, $value) = @_;
    local $_ = $value;
    $self->{handlers}->{on_next}->($_);
}

sub on_complete {
    my $self = shift;
    $self->{handlers}->{on_complete}->();
    $self->dispose;
}

sub on_error {
    my ($self, $err) = @_;
    local $_ = $err;
    $self->{handlers}->{on_error}->($_);
    $self->dispose;
}

sub dispose {
    my $self = shift;
    my $handlers = $self->{handlers};
    $handlers->{$_} = sub { die "broken observer: $_" }
        foreach qw(on_next on_error on_complete);
}

1;

