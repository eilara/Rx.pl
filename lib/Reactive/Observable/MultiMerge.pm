package Reactive::Observable::MultiMerge;

# merge a list of observables

use Moose;
use aliased 'Reactive::Disposable::Composite' => 'CompositeDisposable';

has observables => (is => 'ro', required => 1);

extends 'Reactive::Observable::Composite';

sub initial_subscriptions { @{shift->observables} }

sub build_disposable_parent { CompositeDisposable->new }

sub fill_disposable_parent {
    my ($self, $disposable_parent, @disposables) = @_;
    $disposable_parent->wrap(@disposables);
}

augment observer_args => sub {
    my ($self) = @_;
    return (num_started => scalar(@{$self->observables}), inner(@_));
};

package Reactive::Observable::MultiMerge::Observer;

use Moose;
use Scalar::Util qw(weaken);
use aliased 'Reactive::Disposable::Wrapper' => 'DisposableWrapper';

has num_started   => (is => 'ro', required => 1);
has num_completed => (is => 'rw', default  => 0);

extends 'Reactive::Observer::Wrapper';

sub on_complete {
    my $self = shift;
    my $num_completed = $self->num_completed;
    $self->num_completed(++$num_completed);
    return if $self->num_completed < $self->num_started;
    $self->wrap->on_complete;
    $self->unwrap;
}

1;

