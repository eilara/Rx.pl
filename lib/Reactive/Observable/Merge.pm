package Reactive::Observable::Merge;

use Moose;

extends 'Reactive::Observable::DoubleWrapper';

sub build_wrapper_observer {
    my ($self, %args) = @_;
    return Reactive::Observable::Merge::Observer->
        new(%args);
}

package Reactive::Observable::Merge::Observer;

use Moose;

has num_completed => (is => 'rw', default => 0);

extends 'Reactive::Observer::Forwarder';

sub on_complete {
    my $self = shift;
    if ($self->num_completed == 0) {
        $self->num_completed(1);
        # TODO unwrap parent subscription from this completed subscription?
    } else {
        $self->parent->wrap(undef);
        $self->target->on_complete;
        $self->dispose;
    }
}

1;

