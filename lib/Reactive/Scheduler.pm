package Reactive::Scheduler;
# ABSTRACT: A role defining a reactive scheduler

use Moose::Role;
use Scalar::Util qw(weaken);
use Reactive::Disposable::Wrapper;

requires qw(schedule_once now);

# at is in msec
sub schedule_periodic {
    my ($self, $at, $action) = @_;
    my $disposable = Reactive::Disposable::Wrapper->new;
    $self->_schedule_periodic($at, $action, $disposable);
    return $disposable;
}

sub _schedule_periodic {
    my ($self, $at, $action, $disposable) = @_;
    return unless $disposable; # we have been disposed, fire no more

    weaken $disposable;
    # schedule callback has strong refs to: scheduler, action
    # and a weak ref to: disposable
    my $callback = sub {
        my $new_at = $action->();
        return unless $disposable; # we have been disposed, fire no more
        if (defined $new_at) {
            $self->_schedule_periodic($new_at, $action, $disposable);
        } else {
            $disposable->unwrap;
        }
    };
    my $wrap = $self->schedule_once($at, $callback);
    $disposable->wrap($wrap);
}

1;

__END__

=head1 DESCRIPTION

This role provides the constraints and definitions of any reactive scheduler.
If you implement any scheduler for L<Reactive>, you need to consume this role.

    package Reactive::Scheduler::IOAsync
    use Moose;
    with 'Reactive::Scheduler';

    # implementation left as an exercise to the reader

=head1 REQUIRES

This role requires the consuming class to implement the following methods:

=over 4

=item * schedule_once($at,$action)

Schedule at a specific time (in milliseconds) a new event (provided as a code
reference).

=item * now

The current time in milliseconds, as decided by the event loop.

It will not be called with any arguments.

=back

=head1 METHODS

=head2 schedule_periodic

Schedules a new periodic event.

Uses L<Reactive:::Disposable::Wrapper>.

