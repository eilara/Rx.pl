package Reactive::Observable::Expand;

use Moose;
use aliased 'Reactive::Disposable::Composite' => 'CompositeDisposable';

has projection => (is => 'ro', required => 1);

extends 'Reactive::Observable::Wrapper';

sub build_disposable_parent { CompositeDisposable->new }

sub fill_disposable_parent {
    my ($self, $disposable_parent, @disposables) = @_;
    $disposable_parent->wrap(@disposables);
}

augment observer_args => sub {
    my ($self) = @_;
    return (projection => $self->projection, inner(@_));
};

package Reactive::Observable::Expand::Observer;

use Moose;
use Scalar::Util qw(weaken);
use aliased 'Reactive::Disposable::Wrapper' => 'DisposableWrapper';

has projection  => (is => 'ro', required => 1);
has num_started => (is => 'rw', default  => 1);

extends 'Reactive::Observer::Wrapper';

sub on_next {
    my ($self, $value) = @_;
    $self->{num_started}++;

    local $_ = $value;
    $self->wrap->on_next($value);

    my $next_observable;
    eval {
        $_ = $value;
        $next_observable = $self->projection->($_);
    };
    my $err = $@;
    return $self->on_error($err) if $err;

    my $disposable = DisposableWrapper->new;
    weaken(my $weak_disposable = $disposable);

    my $handle = $next_observable->subscribe(
        on_next     => sub { $self->on_next(shift) },
        on_complete => sub { $self->on_child_complete($weak_disposable) },
        on_error    => sub { $self->on_error(shift) },
    );

    return if $self->is_disposing; # subscription could have caused us
                                   # to deactivate

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

