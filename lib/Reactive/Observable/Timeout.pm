package Reactive::Observable::Timeout;

use Moose;

has timeout     => (is => 'ro', required => 1); # msec
has [qw(o1 o2)] => (is => 'ro', required => 1);

extends 'Reactive::Observable::Composite';

sub initial_subscriptions { (shift->o1) }

augment observer_args => sub {
    my ($self) = @_;
    return (
        scheduler       => $self->scheduler,
        timeout         => $self->timeout,
        next_observable => $self->o2,
        inner(@_),
    );
};

package Reactive::Observable::Timeout::Observer;

use Moose;
use Scalar::Util qw(weaken);
use aliased 'Reactive::Observable' => 'Observable';
use aliased 'Reactive::Disposable::Wrapper' => 'DisposableWrapper';

has scheduler            => (is => 'ro', required => 1, weak_ref => 1);
has timeout              => (is => 'ro', required => 1); # msec
has next_observable      => (is => 'ro', required => 1);
has timeout_subscription => (is => 'rw');

extends 'Reactive::Observer::Wrapper';

sub BUILD {
    my $self = shift;
    weaken(my $weak_self = $self);
    $self->timeout_subscription(
        Observable->timer($self->timeout, $self->scheduler)
                  ->subscribe(sub{ $weak_self->on_timeout })
    );
}

sub on_next {
    my ($self, $value) = @_;
    # cancel timer on 1st on_next since it has not fired yet
    if (defined $self->{next_observable})
        { delete($_[0]->{$_}) for qw(next_observable timeout_subscription) }
    local $_ = $value;
    $self->wrap->on_next($value);
}

sub on_timeout {
    my $self = shift;
    my $next_observable = $self->next_observable;
    delete $self->{next_observable};
    delete $self->{timeout_subscription};
    my $disposable = $next_observable->subscribe_observer($self);
    # new subscription could have completed
    return if $self->is_disposing;
    $self->wrap_with_parent($disposable);
}

before unwrap => sub
    { delete($_[0]->{$_}) for qw(next_observable timeout_subscription) };

1;

