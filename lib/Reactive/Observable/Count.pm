package Reactive::Observable::Count;

use Moose;

extends 'Reactive::Observable::Wrapper';

sub build_wrapper_observer {
    my ($self, %args) = @_;
    return Reactive::Observable::Count::Observer->new(%args);
}

package Reactive::Observable::Count::Observer;

use Moose;

has counter => (is => 'rw', default => 0);

extends 'Reactive::Observer::Forwarder';

sub on_next {
    my ($self) = @_;
    local $_ = $self->counter;
    $_++;
    $self->counter($_);
    $self->target->on_next($_);
}

1;

