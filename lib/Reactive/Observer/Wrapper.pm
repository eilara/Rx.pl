package Reactive::Observer::Wrapper;

use Moose;
use aliased 'Reactive::Observer::Empty' => 'Empty';

# disposable_parent - disposable wrapping subscription to wrapped
#                     observable of wrapped observer
#                     also the subscription of this observer
#                     and thus must be weak, for outside control
#                     of the subscription
has disposable_parent => (is => 'ro', required => 1, weak_ref => 1);
has wrap              => (is => 'ro', required => 1);

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
sub is_disposing { !defined(shift->{disposable_parent}) }

sub wrap_with_parent {
    my ($self, $child) = @_;
    $self->disposable_parent->wrap($child);
}

sub unwrap_parent {
    my ($self, @args) = @_;
    $self->disposable_parent->unwrap(@args);
}

sub unwrap {
    my $self = shift;
    $self->{wrap} = Empty->new;
    $self->unwrap_parent unless $self->is_disposing;
}

1;

