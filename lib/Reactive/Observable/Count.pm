package Reactive::Observable::Count;

use Moose;

extends 'Reactive::Observable::Wrapper';

package Reactive::Observable::Count::Observer;

use Moose;

has counter => (is => 'rw', default => 0);

extends 'Reactive::Observer::Wrapper';

sub on_next {
    my $self = shift;
    local $_ = $self->counter;
    $_++;
    $self->counter($_);
    $self->wrap->on_next($_);
}

1;

