package Reactive::Observable::TakeUntilPredicate;
use Moose;

has predicate => (is => 'ro', required => 1);

extends 'Reactive::Observable::Wrapper';

augment observer_args => sub {
    my ($self) = @_;
    return (predicate => $self->predicate, inner(@_));
};

package Reactive::Observable::TakeUntilPredicate::Observer;

use Moose;

has predicate => (is => 'ro', required => 1);

extends 'Reactive::Observer::Wrapper';

sub on_next {
    my ($self, $value) = @_;
    $self->wrap->on_next($value);

    local $_ = $value;
    my $should_stop;
    eval { $should_stop = $self->predicate->($_) };
    my $err = $@;
    return $self->on_error($err) if $err;
    $self->on_complete if $should_stop;
}

1;
