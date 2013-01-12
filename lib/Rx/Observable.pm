package Rx::Observable;

use strict;
use warnings;
use Moose;
use Rx::Observer;
use Rx::Scheduler;

has scheduler => (
    is         => 'ro',
    lazy_build => 1,
    handles    => [qw(schedule_now)],
);

has on_subscribe   => (is => 'ro', required => 1);
has on_unsubscribe => (is => 'ro', default => sub { sub{} });

sub _build_scheduler {
    my $self = shift;
    return Rx::Scheduler->new;
}

sub subscribe {
    my ($self, %subs) = @_;
    $subs{$_} ||= sub {} foreach qw(on_next on_error on_complete);
    my $observer = Rx::Observer->new(subs => {%subs});
    return $self->schedule_now(sub {
        my $scheduler = shift;
        $self->on_subscribe->($observer, $scheduler);
    }, $self->on_unsubscribe);
}

sub subscribe_observer {
    my ($self, $observer, %subs) = @_;
    return $self->subscribe(
        on_next     => sub { $observer->on_next($_)  },
        on_complete => sub { $observer->on_complete  },
        on_error    => sub { $observer->on_error($_) },
        %subs,
    );
}

sub create {
    my ($class, $on_subscribe, $on_unsubscribe) = @_;
    $class->new(
        on_subscribe   => $on_subscribe,
        on_unsubscribe => $on_unsubscribe || sub {},
    );
}

sub generate {
    my (
        $class,
        $init_value,
        $continue_predicate, 
        $step_action,
        $result_projection,
        $inter_step_duration
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
    });
}

sub map {
    my ($self, $projection) = @_;
    my $class = ref $self;
    my $subscription;
    $class->create(
        sub {
            my ($observer, $scheduler) = @_;
            $subscription = $self->subscribe_observer(
                $observer, on_next => sub
                    { $observer->on_next($projection->($_)) },
            );
        },
        sub {
            undef $subscription;
        },
    );
}

sub grep {
    my ($self, $predicate) = @_;
    my $class = ref $self;
    my $subscription;
    $class->create(
        sub {
            my ($observer, $scheduler) = @_;
            $subscription = $self->subscribe_observer(
                $observer,
                on_next => sub {
                    my $value = $_;
                    $observer->on_next($value) if $predicate->($_);
                },
            );
        },
        sub {
            undef $subscription;
        },
    );
}

sub concat {
    my ($self, $observable) = @_;
    my $class = ref $self;
    my $subscription;
    $class->create(
        sub {
            my ($observer, $scheduler) = @_;
            $subscription = $self->subscribe_observer(
                $observer, on_complete => sub
                    { $subscription = $self->subscribe_observer($observer) },
            );
        },
        sub {
            undef $subscription;
        },
    );
}

sub count {
    my ($self, $observable) = @_;
    my $class = ref $self;
    my $subscription;
    $class->create(
        sub {
            my ($observer, $scheduler) = @_;
            my $counter = 1;
            $subscription = $self->subscribe_observer(
                $observer, on_next => sub
                    { $observer->on_next($counter++) },
            );
        },
        sub {
            undef $subscription;
        },
    );
}

1;

__END__
