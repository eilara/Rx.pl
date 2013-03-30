package Reactive::Observable::Push;

use Moose;

has [qw(o1 o2)] => (is => 'ro', required => 1);

extends 'Reactive::Observable::Composite';

sub initial_subscriptions { (shift->o1) }

augment observer_args => sub {
    my $self = shift;
    return (next_observable => $self->o2, inner(@_));
};

package Reactive::Observable::Push::Observer;

use Moose;

has next_observable => (is => 'rw', required => 1);

extends 'Reactive::Observer::Wrapper';

sub on_complete {
    my $self = shift;
    my $method = 'on_complete_'. ($self->next_observable? 1: 2);
    $self->$method;
}

sub on_complete_1 {
    my $self = shift;
    my $next_observable = $self->next_observable;
    $self->next_observable(undef);
    my $disposable = $next_observable->subscribe_observer($self);
    # new subscription could have completed
    $self->wrap_with_parent($disposable)
        if $self->wrap; # we have not been unwrapped yet
}

sub on_complete_2 {
    my $self = shift;
    $self->wrap->on_complete;
    $self->unwrap;
}

before unwrap => sub { delete shift->{next_observable} };

1;

