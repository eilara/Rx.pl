package Reactive::Observable::Concat;

use Moose;
use aliased 'Reactive::Disposable::Wrapper' => 'DisposableWrapper';

has [qw(o1 o2)] => (is => 'ro', required => 1);

extends 'Reactive::Observable';

sub run {
    my ($self, $observer)  = @_;
    my ($o1, $o2)          = ($self->o1, $self->o2);
    my $disposable_wrapper = DisposableWrapper->new;
    my $observer_pkg       = __PACKAGE__. '::Observer';
    my $disposable         = $o1->subscribe_observer(
       $observer_pkg->new(
           wrap               => $observer,
           next_observable    => $o2,
           disposable_wrapper => $disposable_wrapper,
       )
    );
    $disposable_wrapper->wrap($disposable);
    return $disposable_wrapper;
}

package Reactive::Observable::Concat::Observer;

use Moose;

# disposable_wrapper - disposable wrapping subscription to wrapped
#                      observable of wrapped observer
#                      also the subscription of this observer
#                      and thus must be weak, for outside control
#                      of the subscription

has disposable_wrapper => (is => 'ro', required => 1, weak_ref => 1);
has next_observable    => (is => 'rw', required => 1);

extends 'Reactive::Observer::Wrapper';

sub on_complete {
    my $self = shift;
    my $method = 'on_complete_'. ($self->next_observable? 1: 2);
    $self->$method;
}

sub on_complete_1 {
    my $self = shift;
    $self->disposable_wrapper->unwrap;
    my $next_observable = $self->next_observable;
    $self->next_observable(undef);
    my $disposable = $next_observable->subscribe_observer($self);
    # new subscription could have completed
    $self->disposable_wrapper->wrap($disposable)
        if $self->wrap; # we have not been unwrapped yet
}

sub on_complete_2 {
    my $self = shift;
    $self->wrap->on_complete;
    $self->unwrap;
}

before unwrap => sub { delete shift->{next_observable} };

1;

