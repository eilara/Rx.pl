package Reactive::Observable::DistinctChanges;

use Moose;

extends 'Reactive::Observable::Wrapper';

sub build_wrapper_observer {
    my ($self, %args) = @_;
    return Reactive::Observable::DistinctChanges::Observer->new(
        %args,
    );
}

package Reactive::Observable::DistinctChanges::Observer;

use Moose;

has last_value => (is => 'rw');

extends 'Reactive::Observer::Forwarder';

sub on_next {
    my ($self, $value) = @_;
    my $last_value = $self->last_value;
    $self->last_value($value);
    return unless defined $last_value;
    return if $value ~~ $last_value;
    $self->target->on_next($value);
}

1;

