package Reactive::Observable::Merge;

use Moose;
use aliased 'Reactive::Disposable::Wrapper';

has o1 => (is => 'ro', required => 1);
has o2 => (is => 'ro', required => 1);

extends 'Reactive::Observable';

sub run {
    my ($self, $observer) = @_;
    my $subscription = Wrapper->new;
    my $wrapper_observer = Reactive::Observable::Merge::Observer->new(
        parent => $subscription,
        target => $observer,
    );
    my $s1 = $self->o1->subscribe_observer($wrapper_observer);
    my $s2 = $self->o2->subscribe_observer($wrapper_observer);
    $subscription->wrap([$s1, $s2]);
    return $subscription;
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

