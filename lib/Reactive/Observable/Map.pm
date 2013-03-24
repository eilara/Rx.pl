package Reactive::Observable::Map;

use Moose;

extends 'Reactive::Observable::Wrapper';

has projection => (is => 'ro', required => 1);

augment observer_args => sub {
    my ($self) = @_;
    return (projection => $self->projection, inner(@_));
};

package Reactive::Observable::Map::Observer;

use Moose;

has projection => (is => 'ro', required => 1);

extends 'Reactive::Observer::Wrapper';

sub on_next {
    my ($self, $value) = @_;
    local $_ = $value;
    my $new_value = $self->projection->($_);
    $self->wrap->on_next($new_value);
}

1;

