package Reactive::Scheduler::Coro;
# ABSTRACT: A Coro-based reactive scheduler

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

__END__

=head1 DESCRIPTION

This scheduler allows to schedule reactive events using L<Coro>.

=head1 METHODS

=head2 now

The current time via L<EV>.

=head2 schedule_once

Schedule a new action via L<AE>.

