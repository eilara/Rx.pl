package Reactive::Observer::Wrapper;

use Moose;

has wrap => (is => 'ro', required => 1);

sub on_next {
    my ($self, $value) = @_;
    local $_ = $value;
    $self->wrap->on_next($value);
}

sub on_complete {
    my $self = shift;
    $self->wrap->on_complete;
    $self->unwrap;
}

sub on_error {
    my ($self, $err) = @_;
    local $_ = $err;
    $self->wrap->on_error($_);
    $self->unwrap;
}

sub unwrap { delete shift->{wrap} }

1;

