package Reactive::Observable::Grep;

use Moose;

extends 'Reactive::Observable::Wrapper';

has predicate => (is => 'ro', required => 1);

augment observer_args => sub {
    my ($self) = @_;
    return (predicate => $self->predicate, inner(@_));
};

package Reactive::Observable::Grep::Observer;

use Moose;

has predicate => (is => 'ro', required => 1);

extends 'Reactive::Observer::Wrapper';

sub on_next {
    my ($self, $value) = @_;
    local $_ = $value;
    $self->wrap->on_next($value) if $self->predicate->($_);
}

1;

