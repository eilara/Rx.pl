package Reactive::Observable::Skip;

use Moose;

has count => (is => 'ro', required => 1);

extends 'Reactive::Observable::Wrapper';

augment observer_args => sub {
    my ($self) = @_;
    return (count => $self->count, inner(@_));
};

package Reactive::Observable::Skip::Observer;

use Moose;

has count   => (is => 'ro', required => 1);
has skipped => (is => 'rw', default  => 0);

extends 'Reactive::Observer::Wrapper';

sub on_next {
    my ($self, $value) = @_;
    my $skipped = $self->skipped;
    if ($skipped >= $self->count) {
        $self->wrap->on_next($value);
    } else {
        $self->skipped($skipped + 1);
    }
}

1;

