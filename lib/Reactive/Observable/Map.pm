package Reactive::Observable::Map;

use strict;
use warnings;
use Moose;

extends 'Reactive::Observable::Wrapper';

has projection => (is => 'ro', required => 1);

sub build_wrapper_observer {
    my ($self, %args) = @_;
    return Reactive::Observable::Map::Observer->new(
        %args,
        projection => $self->projection,
    );
}

package Reactive::Observable::Map::Observer;

use strict;
use warnings;
use Moose;

has projection => (is => 'ro', required => 1);

extends 'Reactive::Observer::Forwarder';

sub on_next {
    my ($self, $value) = @_;
    local $_ = $value;
    my $new_value = $self->projection->($_);
    $self->target->on_next($new_value);
}

1;

