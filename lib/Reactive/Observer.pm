package Reactive::Observer;

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
    $self->unwrap;
}

sub on_error {
    my ($self, $err) = @_;
    local $_ = $err;
    $self->{handlers}->{on_error}->($_);
    $self->unwrap;
}

sub unwrap { delete shift->{handlers} }

1;

