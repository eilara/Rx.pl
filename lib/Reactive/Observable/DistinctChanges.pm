package Reactive::Observable::DistinctChanges;

use Moose;

extends 'Reactive::Observable::Wrapper';

package Reactive::Observable::DistinctChanges::Observer;

use Moose;

has last_value => (is => 'rw');

extends 'Reactive::Observer::Wrapper';

sub on_next {
    my ($self, $value) = @_;
    my $last_value = $self->last_value;
    $self->last_value($value);
    return if defined($last_value) && $value ~~ $last_value;
    $self->wrap->on_next($value);
}

1;

