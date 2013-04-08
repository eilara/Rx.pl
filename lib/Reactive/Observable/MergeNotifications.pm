package Reactive::Observable::MergeNotifications;

# merge observables that are the notifications of an observable

# completes when main and notification observables complete

use Moose;
use aliased 'Reactive::Disposable::Composite' => 'CompositeDisposable';

extends 'Reactive::Observable::Wrapper';

sub build_disposable_parent { CompositeDisposable->new }

sub fill_disposable_parent {
    my ($self, $disposable_parent, @disposables) = @_;
    $disposable_parent->wrap(@disposables);
}

package Reactive::Observable::MergeNotifications::Observer;

use Moose;
use Scalar::Util qw(weaken);
use aliased 'Reactive::Disposable::Wrapper' => 'DisposableWrapper';

has num_started => (is => 'rw', default => 1);

extends 'Reactive::Observer::Wrapper';

sub on_next {
    my ($self, $value) = @_;
    $self->{num_started}++;

    my $disposable = DisposableWrapper->new;
    weaken (my $weak_disposable = $disposable);

    my $handle = $value->subscribe(
        on_next     => sub { $self->wrap->on_next(shift) },
        on_complete => sub { $self->on_child_complete($weak_disposable) },
        on_error    => sub { $self->on_error(shift) },
    );

    $disposable->wrap($handle);
    $self->wrap_with_parent($disposable);
}

sub on_child_complete {
    my ($self, $child_disposable) = @_;
    return if $self->is_disposing;
    $self->unwrap_parent($child_disposable) if $child_disposable;
    $self->on_complete_final if --$self->{num_started} == 0;
}

sub on_complete { shift->on_child_complete }

sub on_complete_final {
    my $self = shift;
    $self->wrap->on_complete;
    $self->unwrap;
}

1;

