package Reactive::Observable::Concat;

use strict;
use warnings;
use Moose;

extends 'Reactive::Observable::Wrapper';

has next_observable => (is => 'ro', required => 1);

sub build_wrapper_observer {
    my ($self, %args) = @_;
    return Reactive::Observable::Concat::Observer->new(
        %args,
        next_observable => $self->next_observable,
    );
}

package Reactive::Observable::Concat::Observer;

use strict;
use warnings;
use Moose;

has next_observable => (is => 'rw', required => 1);

extends 'Reactive::Observer::Forwarder';

sub on_complete {
    my $self = shift;
    if ($self->next_observable) {
        my $new_subscription = $self->next_observable
                                    ->subscribe_observer($self);
        $self->parent->wrap->dispose;
        $self->parent->wrap($new_subscription);
        $self->next_observable(undef);
    } else {
        $self->target->on_complete();
        $self->dispose;
    }
}

before dispose => sub {
    my $self = shift;
    $self->{next_observable} = undef;
};

1;

