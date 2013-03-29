package Reactive::Observable::Delay;

use Moose;
use aliased 'Reactive::Disposable::Composite' => 'CompositeDisposable';

extends 'Reactive::Observable::Wrapper';

has delay => (is => 'ro', required => 1); # msec

sub build_disposable_parent { CompositeDisposable->new }

sub fill_disposable_parent {
    my ($self, $disposable_parent, @disposables) = @_;
    $disposable_parent->wrap(@disposables);
}

augment observer_args => sub {
    my ($self, $observer, $disposable_parent) = @_;
    return (
        delay             => $self->delay,
        disposable_parent => $disposable_parent,
        scheduler         => $self->scheduler,
        inner(@_),
    );
};

package Reactive::Observable::Delay::Observer;

use Moose;
use Scalar::Util qw(weaken);
use aliased 'Reactive::Disposable::Wrapper' => 'DisposableWrapper';

has delay             => (is => 'ro', required => 1); # msec
has disposable_parent => (is => 'ro', required => 1, weak_ref => 1);
has scheduler         => (is => 'ro', required => 1, weak_ref => 1,
                          handles => [qw(schedule_once)]);

extends 'Reactive::Observer::Wrapper';

sub on_next {
    my ($self, $value) = @_;

    # scheduler must not keep strong ref to disposable parent
    weaken(my $disposable_parent = $self->disposable_parent);
    # but can keep strong ref to wrapped observer, as we do
    my $wrap = $self->wrap;
    # and a weak ref to the timer handle, which is held 
    # in the disposable parent with a strong ref
    my $disposable = DisposableWrapper->new;
    weaken (my $weak_disposable = $disposable);

    my $handle = $self->schedule_once($self->delay, sub {
        return unless $disposable_parent;
        $disposable_parent->unwrap($weak_disposable);
        $wrap->on_next($value);
    });
    $disposable->wrap($handle);
    $disposable_parent->wrap($disposable);
}

before unwrap => sub {
    my $self = shift;
    $self->disposable_parent->unwrap
        if $self->disposable_parent;
};

1;

