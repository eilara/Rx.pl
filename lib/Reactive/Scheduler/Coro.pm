package Reactive::Scheduler::Coro;

use Moose;
use EV;
use Coro::AnyEvent;

with 'Reactive::Scheduler';

sub now { EV::time * 1000 } # msec

sub schedule_once {
    my ($self, $at, $action) = @_;
    return AE::timer $at/1000, 0, $action;
}

1;
