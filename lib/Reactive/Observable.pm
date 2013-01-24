package Reactive::Observable;

use Moose;
use Reactive::Scheduler::Coro;
use aliased 'Reactive::Observer';
use aliased 'Reactive::Observable::Once';
use aliased 'Reactive::Observable::Range';
use aliased 'Reactive::Observable::Generate';
use aliased 'Reactive::Observable::Map';
use aliased 'Reactive::Observable::Grep';
use aliased 'Reactive::Observable::Count';
use aliased 'Reactive::Observable::Concat';
use aliased 'Reactive::Observable::Take';
use aliased 'Reactive::Observable::FromStdIn';

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

# creating --------------------------------------------------------------------

sub once {
    my ($class, $value, $scheduler) = @_;
    return Once->new(value => $value, maybe_scheduler $scheduler);
}

sub range {
    my ($class, $from, $size, $scheduler) = @_;
    return Range->new
        (from => $from, size => $size, maybe_scheduler $scheduler);
}

# from time --------------------------------------------------------------------

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

sub timer {
    my ($class, $duration, $scheduler) = @_;
    return Generate->new(
        init_value          => 0,
        continue_predicate  => sub { 0 },
        step_action         => sub { $_ },
        result_projection   => sub { 1 },
        inter_step_duration => sub { $duration },
        maybe_scheduler $scheduler,
    );
}

# from IO ----------------------------------------------------------------------

sub from_stdin {
    my ($class, $scheduler) = @_;
    return FromStdIn->new(maybe_scheduler $scheduler);
}

# projections ------------------------------------------------------------------

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

sub count {
    my ($self, $scheduler) = @_;
    return Count->new(
        source => $self,
        maybe_scheduler $scheduler,
    );
}

sub concat {
    my ($self, $next_observable, $scheduler) = @_;
    return Concat->new(
        source          => $self,
        next_observable => $next_observable, 
        maybe_scheduler $scheduler,
    );
}

sub take {
    my ($self, $max, $scheduler) = @_;
    return Take->new(
        source => $self,
        max    => $max,
        maybe_scheduler $scheduler,
    );
}

# anamorphisms -----------------------------------------------------------------

1;
