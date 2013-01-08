package Rx::Scheduler;

use strict;
use warnings;
use Moose;
use Coro;
use Coro::EV;
use Coro::AnyEvent;
use Rx::Disposable;

sub schedule_now {
    my ($self, $action, $on_cancel) = @_;
    my $coro = async { $action->($self) };
    return Rx::Disposable->new(cleanup => sub {
        $coro->cancel;
        $on_cancel->();
    });
}

sub rest {
    my ($self, $duration) = @_;
    Coro::AnyEvent::sleep $duration->seconds;
}

1;
