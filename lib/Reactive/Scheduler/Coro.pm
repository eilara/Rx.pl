package Reactive::Scheduler::Coro;

use strict;
use warnings;
use Scalar::Util qw(weaken);
use Moose;
use Coro;
use Coro::EV;
use Coro::AnyEvent;
use Reactive::Disposable::Coro;
use Reactive::Disposable::Timer;

with 'Reactive::Scheduler';

sub schedule_now {
    my ($self, $action) = @_;
    my $coro = async { $action->() };
    my $subscription = Reactive::Disposable::Coro->new(coro => $coro);
    return $subscription;
}

# at is in msec
sub schedule_at {
    my ($self, $at, $action) = @_;
    my $subscription = Reactive::Disposable::Timer->new;
    $self->_schedule_at($at, $action, $subscription);
    return $subscription;
}

sub _schedule_at {
    my ($self, $at, $action, $disposable) = @_;
    weaken $disposable;
    $disposable->timer(
        AE::timer $at/1000, 0, sub {
            my $new_at = $action->();
            if (defined $new_at) {
                $self->_schedule_at($new_at, $action, $disposable);
            } else {
                $disposable->dispose;
            }
        }
    );
}

1;
