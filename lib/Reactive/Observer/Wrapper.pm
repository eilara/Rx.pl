package Reactive::Observer::Wrapper;

use Moose;
use aliased 'Reactive::Observer::Empty' => 'Empty';

# disposable_parent - disposable wrapping subscription to wrapped
#                     observable of wrapped observer
#                     also the subscription of this observer
#                     and thus must be weak, for outside control
#                     of the subscription
#                     TODO: surely there is a better way to explain that
has disposable_parent => (is => 'ro', required => 1, weak_ref => 1);
has wrap              => (is => 'ro', required => 1);

=encoding utf8

=head1 NAME

Reactive::Observer::Wrapper - base class for wrapping an observer.

=head1 SYNOPSIS

    use Moose;

    has count => (is => 'ro', required => 1);
    has taken => (is => 'rw', default  => 0);

    extends 'Reactive::Observer::Wrapper';

    sub on_next {
        my ($self, $value) = @_;
        $self->wrap->on_next($value);
        my $taken = $self->taken + 1;
        $self->taken($taken);
        $self->on_complete if $taken >= $self->count;
    }

    1;

=head1 METHODS

=head2 $self->wrap()

A read only slot for the observer getting wrapped.

=head2 $self->disposable_parent()

A disposable wrapping subscription to wrapped observable of wrapped observer
also the subscription of this observer and thus must be weak, for outside
control of the subscription. B<TODO:> surely there is a better way to explain
that.

=head2 $self->on_next()

Wraps wrap()’s on_next().

=head2 $self->on_complete().

Wraps wrap()’s on_complete().

=head2 $self->on_error()

Wraps wrap()’s on_error().

=cut

sub on_next {
    my ($self, $value) = @_;
    local $_ = $value;
    $self->wrap->on_next($value);
}

sub on_complete {
    my $self = shift;
    $self->wrap->on_complete;
    $self->unwrap;
}

sub on_error {
    my ($self, $err) = @_;
    local $_ = $err;
    $self->wrap->on_error($_);
    $self->unwrap;
}

# has my subscription vanished, could be before we complete or unwrap

=head2 is_disposing()

Whether the current parent has been disposed.

=cut

sub is_disposing { !defined(shift->{disposable_parent}) }

=head2 $self->wrap_with_parent($child)

Make disposable_parent() wrap $child as well.

=cut

sub wrap_with_parent {
    my ($self, $child) = @_;
    $self->disposable_parent->wrap($child);
}

=head2 $self->unwrap_parent(@args)

Call disposable_parent()’s unwrap with @args .

=cut

sub unwrap_parent {
    my ($self, @args) = @_;
    $self->disposable_parent->unwrap(@args);
}

=head2 $self->unwrap()

Unwrap $self->wrap().

=cut

sub unwrap {
    my $self = shift;
    # O->once(1)->take(1) for example, requires that we not delete
    # the wrapped observer, but replace with Empty because more
    # notifications will arrive: a call to on_complete
    $self->{wrap} = Empty->new;
    $self->unwrap_parent unless $self->is_disposing;
}

1;

