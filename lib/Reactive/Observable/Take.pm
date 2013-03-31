package Reactive::Observable::Take;

use Moose;

has max => (is => 'ro', required => 1);

extends 'Reactive::Observable::Wrapper';

augment observer_args => sub {
    my ($self) = @_;
    return (max => $self->max, inner(@_));
};

package Reactive::Observable::Take::Observer;

use Moose;

has max   => (is => 'ro', required => 1);
has taken => (is => 'rw', default  => 0);

extends 'Reactive::Observer::Wrapper';

sub on_next {
    my ($self, $value) = @_;
    $self->wrap->on_next($value);
    my $taken = $self->taken + 1;
    $self->taken($taken);
    $self->on_complete if $taken >= $self->max;
}

1;

