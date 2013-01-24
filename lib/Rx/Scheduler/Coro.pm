package Rx::Scheduler::Coro;

use strict;
use warnings;
use Moose;
use Coro;
use Coro::EV;
use Coro::AnyEvent;
use Reactive::Disposable::Coro;

with 'Rx::Scheduler';

sub schedule_now {
    my ($self, $action) = @_;
    my $coro = async { $action->($self) };
    my $subscription = Rx::Disposable::Coro->new(coro => $coro);
    return $subscription;
}

sub rest {
    my ($self, $duration) = @_;
    Coro::AnyEvent::sleep $duration->seconds;
}

1;
