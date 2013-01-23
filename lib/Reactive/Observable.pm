package Reactive::Observable;

use strict;
use warnings;
use Moose;
use Reactive::Scheduler::Coro;
use aliased 'Reactive::Observer';
use aliased 'Reactive::Observable::Once';
use aliased 'Reactive::Observable::Range';
use aliased 'Reactive::Observable::Generate';
use aliased 'Reactive::Observable::Map';
use aliased 'Reactive::Observable::Grep';

has scheduler => (
    is         => 'ro',
    lazy_build => 1,
    handles    => [qw(schedule_now schedule_at)],
);

sub _build_scheduler { Reactive::Scheduler::Coro->new }

sub subscribe {
    my ($self, %handlers) = @_;
    $handlers{$_} ||= sub {} foreach qw(on_next on_error on_complete);
    my $observer = Observer->new(handlers => {%handlers});
    return $self->subscribe_observer($observer);
}

sub subscribe_observer {
    my ($self, $observer) = @_;
    return $self->run($observer);
}

sub maybe_scheduler($) { $_[0]? (scheduler => $_[0]): () }

sub once {
    my ($class, $value, $scheduler) = @_;
    return Once->new(value => $value, maybe_scheduler $scheduler);
}

sub range {
    my ($class, $from, $size, $scheduler) = @_;
    return Range->new
        (from => $from, size => $size, maybe_scheduler $scheduler);
}

sub interval {
    my ($class, $duration, $scheduler) = @_;
    return Generate->new(
        init_value          => 0,
        continue_predicate  => sub { 1 },
        step_action         => sub { 1 + $_ },
        result_projection   => sub { $_ },
        inter_step_duration => sub { $duration },
        maybe_scheduler $scheduler,
    );
}

sub map {
    my ($self, $projection, $scheduler) = @_;
    return Map->new(
        source     => $self,
        projection => $projection, 
        maybe_scheduler $scheduler,
    );
}

sub grep {
    my ($self, $predicate, $scheduler) = @_;
    return Grep->new(
        source    => $self,
        predicate => $predicate, 
        maybe_scheduler $scheduler,
    );
}

1;
