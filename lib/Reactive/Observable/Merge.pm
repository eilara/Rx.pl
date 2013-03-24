package Reactive::Observable::Merge;

use Moose;

extends 'Reactive::Observable::DoubleWrapper';

package Reactive::Observable::Merge::Observer;

use Moose;

has num_completed => (is => 'rw', default => 0);

extends 'Reactive::Observer::Wrapper';

sub on_complete {
    my $self = shift;
    return $self->num_completed(1) if $self->num_completed == 0;
    $self->wrap->on_complete;
    $self->unwrap;
}

1;

