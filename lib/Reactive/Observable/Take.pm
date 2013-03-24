package Reactive::Observable::Take;

use Moose;

has max => (is => 'ro', required => 1);

extends 'Reactive::Observable::Wrapper';

augment observer_args => sub {
    my ($self, $observer, $disposable_wrapper) = @_;
    return (
        max                => $self->max,
        disposable_wrapper => $disposable_wrapper,
        inner(@_),
    );
};

package Reactive::Observable::Take::Observer;

use Moose;

has max                => (is => 'ro', required => 1);
has taken              => (is => 'rw', default  => 0);
has disposable_wrapper => (is => 'ro', required => 1, weak_ref => 1);

extends 'Reactive::Observer::Wrapper';

sub on_next {
    my ($self, $value) = @_;
    $self->wrap->on_next($value);
    my $taken = $self->taken + 1;
    $self->taken($taken);
    if ($taken >= $self->max) {
        $self->on_complete;
        # which could have disappeared during during on_complete
        $self->disposable_wrapper->unwrap
            if $self->disposable_wrapper;
    }
}

1;

