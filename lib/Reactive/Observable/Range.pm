package Reactive::Observable::Range;

use Moose;
use aliased 'Reactive::Disposable';

extends 'Reactive::Observable';

has [qw(from size)] => (is => 'ro', required => 1);

sub run {
    my ($self, $observer) = @_;
    my $from = $self->from;
    my $i    = $from;
    my $to   = $from + $self->size;
    while ($i < $to) { $observer->on_next($i++) }
    $observer->on_complete;
    return Disposable->empty;
}


1;

