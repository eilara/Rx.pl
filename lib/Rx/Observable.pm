package Rx::Observable;

use strict;
use warnings;
use Moose;
use Rx::Observer;
use Rx::Scheduler::Coro;
use Rx::Observable::Combinators;

has scheduler => (
    is         => 'ro',
    lazy_build => 1,
    handles    => [qw(schedule_now)],
);

has on_subscribe   => (is => 'ro', required => 1);
has on_unsubscribe => (is => 'ro', default => sub { sub{} });

sub _build_scheduler { Rx::Scheduler::Coro->new }

sub subscribe {
    my ($self, %subs) = @_;
    $subs{$_} ||= sub {} foreach qw(on_next on_error on_complete);
    my $observer = Rx::Observer->new(subs => {%subs});
    return $self->schedule_now(sub {
        my $scheduler = shift;
        $self->on_subscribe->($observer, $scheduler);
    }, $self->on_unsubscribe);
}

# sugar for subscribing an existing observer to an observable
# useful for subscribing to a parent observable in a child
# on_subscribe closure while only overriding required 
# notifications
sub subscribe_observer {
    my ($self, $observer, %subs) = @_;
    return $self->subscribe(
        on_next     => sub { $observer->on_next($_)  },
        on_complete => sub { $observer->on_complete  },
        on_error    => sub { $observer->on_error($_) },
        %subs,
    );
}

# create an observable with a closure to run on subscribe
# and optional unsubscribe closure and/or scheduler
# your on_subscribe closure can block because it will
# be run in a new coro by the scheduler, and not on the coro
# that called subscribe on the observable
# this is class method
sub create {
    my ($class, $on_subscribe, @more) = @_;
    my ($on_unsubscribe, $scheduler) =
        @more == 0? (undef, undef):
        @more == 2? (@more):
        ref($more[0]) eq 'CODE'? ($more[0], undef): (undef, $more[0]);
    return $class->new(
        on_subscribe   => $on_subscribe,
        on_unsubscribe => $on_unsubscribe || sub {},
        ($scheduler? (scheduler => $scheduler): ()),
    );
}

# another observable constructor, this time from another
# observable not from the class
# create an observable with a parent: another observable
# to which we subscribe
# you still have to provide a on_subscribe closure
# just like when using the class method create()
# except this is an object not a class method
# and your on_subscribe cannot block, and must immediately
# return a subscription
# this subscription is kept in the new observable created
# and disposed when we are unsubscribed so you dont need to
# maintain it
# you also get an extra arg for the on_subscribe closure you 
# provide- a closure that sets a new subscription
#
# on_subscribe closure of new observable should subscribe to
# $self or some other observable, with closures that notify
# the provided observer with values projected/filtered etc.
# from $self notifications
#
# scheduler on new observable is copied from self
#
# e.g. create an observable that passes notifications unchanged
# from its parent, effectively subscribing to the parent
# observable whenever new observable is subscribed:
#   $parent->create_with_parent(sub {
#       my ($observer, $scheduler, $set_subscription) = @_;
#       return $self->subscribe(
#           on_next     => sub { $observer->on_next($_)  },
#           on_complete => sub { $observer->on_complete  },
#           on_error    => sub { $observer->on_error($_) },
#       );
#   });
# or the same with subscribe_observer sugar:
#   $parent->create_with_parent(sub {
#       my ($observer, $scheduler, $set_subscription) = @_;
#       return $self->subscribe_observer($observer);
#   });
#
sub create_with_parent {
    my ($self, $on_subscribe) = @_;
    my $class = ref $self;
    my $subscription;
    my $changer = sub { $subscription = shift };
    return $class->create(
        sub { $subscription = $on_subscribe->(@_, $changer) },
        sub { $subscription = undef },
        $self->scheduler,
    );
}

# sugar on create_with_parent- instead of writing the on_subscribe
# closure where you subscribe to some parent observable
# simply provide a closure which returns on_next/complete/error
# hash of key => closure
# we will subscribe to the parent observable ($self) for you
# you just need to provide how you will react to notifications
# in the new observable
# you need only provide the pairs where you don't want the default
# behavior, which is just pass all notifications from parent
#
# e.g. this creates an observable from a parent, which will
# subscribe/unsubscribe from the parent when it is subscribed/unsubscribed
# and pass every event verbatim from the parent to subscribers:
#   $observable->create_on_parent(sub {()});
# returning empty hash means we want default behavior
# here is an observable which doubles the values notified by
# its parent:
#   $observable->create_on_parent(sub {(on_next => sub { 2 * $_ })});
sub create_on_parent {
    my ($self, $subscribe_observer) = @_;
    return $self->create_with_parent(sub{
        my ($observer, $scheduler, $changer) = @_;
        return $self->subscribe_observer(
            $observer,
            $subscribe_observer->($observer, $scheduler, $changer),
        );
    });
}

# blocking observable constructor for timers and intervals
# class method
sub generate {
    my (
        $class,
        $init_value,
        $continue_predicate, 
        $step_action,
        $result_projection,
        $inter_step_duration,
        $scheduler,
    ) = @_;
    $class->create(sub {
        my ($observer, $scheduler) = @_;
        my $state = $init_value;
        local $_;
        my $is_first = 1;
        do {
            $_ = $state;
            my $duration = $inter_step_duration->($_);
            $scheduler->rest($duration);

            if ($is_first) { $is_first = 0 }
                      else { $state = $step_action->($_) }

            $_ = $state;
            my $result = $result_projection->($_);
            $observer->on_next($result);
            $_ = $state;

        } until (!($continue_predicate->($_)));
        $observer->on_complete;
    }, $scheduler);
}

1;
