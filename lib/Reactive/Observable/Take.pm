package Reactive::Observable::Take;

use Moose;

extends 'Reactive::Observable::Wrapper';

has max => (is => 'ro', required => 1);

sub build_wrapper_observer {
    my ($self, %args) = @_;
    return Reactive::Observable::Take::Observer->new(
        %args,
        max => $self->max,
    );
}

package Reactive::Observable::Take::Observer;

use Moose;

has max   => (is => 'ro', required => 1);
has taken => (is => 'rw', default  => 0);

extends 'Reactive::Observer::Forwarder';

sub on_next {
    my ($self, $value) = @_;
    $self->target->on_next($value);
    my $taken = $self->taken + 1;
    $self->taken($taken);
    if ($taken >= $self->max) {
        $self->parent->wrap(undef);
        $self->on_complete;
    }
}

1;

