package Reactive::Observable::DoubleWrapper;

use Moose;

has [qw(o1 o2)] => (is => 'ro', required => 1);

extends 'Reactive::Observable::Composite';

sub initial_subscriptions { ($_[0]->map_o1, $_[0]->map_o2) }

sub map_o1 { shift->o1 }
sub map_o2 { shift->o2 }

1;

