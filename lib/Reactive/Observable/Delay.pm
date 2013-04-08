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
    my ($self) = @_;
    return (
        delay     => $self->delay,
        scheduler => $self->scheduler,
        inner(@_),
    );
};

package Reactive::Observable::Delay::Observer;

use Moose;
use Scalar::Util qw(weaken);
use aliased 'Reactive::Disposable::Wrapper' => 'DisposableWrapper';

has delay     => (is => 'ro', required => 1); # msec
has scheduler => (is => 'ro', required => 1, weak_ref => 1,
                  handles => [qw(schedule_once)]);

extends 'Reactive::Observer::Wrapper';

sub on_next {
    my ($self, $value) = @_;

    # can keep strong ref to wrapped observer, as this object does
    my $wrap = $self->wrap;
    # and a weak ref to the timer handle, which is held 
    # in the disposable parent with a strong ref
    my $disposable = DisposableWrapper->new;
    weaken (my $weak_disposable = $disposable);

    my $handle = $self->schedule_once($self->delay, sub {
        return if $self->is_disposing;
        $self->unwrap_parent($weak_disposable);
        $wrap->on_next($value);
    });
    $disposable->wrap($handle);
    $self->wrap_with_parent($disposable);
}

1;

