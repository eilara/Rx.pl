package Reactive::Observable::Grep;

use strict;
use warnings;
use Moose;

extends 'Reactive::Observable::Wrapper';

has predicate => (is => 'ro', required => 1);

sub build_wrapper_observer {
    my ($self, $forward_to, $parent) = @_;
    return Reactive::Observable::Grep::Observer->new(
        parent    => $parent,
        target    => $forward_to,
        predicate => $self->predicate,
    );
}

package Reactive::Observable::Grep::Observer;

use strict;
use warnings;
use Moose;

has predicate => (is => 'ro', required => 1);

extends 'Reactive::Observer::Forwarder';

sub on_next {
    my ($self, $value) = @_;
    local $_ = $value;
    $self->target->on_next($value)
        if $self->predicate->($_);
}

1;

