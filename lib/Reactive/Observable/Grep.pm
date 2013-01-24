package Reactive::Observable::Grep;

use Moose;

extends 'Reactive::Observable::Wrapper';

has predicate => (is => 'ro', required => 1);

sub build_wrapper_observer {
    my ($self, %args) = @_;
    return Reactive::Observable::Grep::Observer->new(
        %args,
        predicate => $self->predicate,
    );
}

package Reactive::Observable::Grep::Observer;

use Moose;

has predicate => (is => 'ro', required => 1);

extends 'Reactive::Observer::Forwarder';

sub on_next {
    my ($self, $value) = @_;
    local $_ = $value;
    $self->target->on_next($value)
        if $self->predicate->($_);
}

1;

