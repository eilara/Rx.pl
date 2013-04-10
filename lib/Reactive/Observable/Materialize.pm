package Reactive::Observable::Materialize;

use Moose;

extends 'Reactive::Observable::Wrapper';

package Reactive::Observable::Materialize::Observer;

use Moose;

extends 'Reactive::Observer::Wrapper';

my ($On_Next, $On_Complete, $On_Error) =
    map { "Reactive::Observable::Materialize::Notification::$_" }
    qw(Next Complete Error);

sub on_next {
    my ($self, $in) = @_;
    my $out = $On_Next->new(wrap => $in);
    local $_ = $out;
    $self->wrap->on_next($out);
}

sub on_complete {
    my $self = shift;
    my $out = $On_Complete->new;
    local $_ = $out;
    $self->wrap->on_next($out);
    $self->wrap->on_complete;
    $self->unwrap;
}

sub on_error {
    my ($self, $in) = @_;
    my $out = $On_Error->new(wrap => $in);
    local $_ = $out;
    $self->wrap->on_next($out);
    $self->wrap->on_complete;
    $self->unwrap;
}

package Reactive::Observable::Materialize::Notification::Next;
use Moose;
has wrap => (is => 'ro', required => 1);

package Reactive::Observable::Materialize::Notification::Complete;
use Moose;

package Reactive::Observable::Materialize::Notification::Error;
use Moose;
has wrap => (is => 'ro', required => 1);

1;

