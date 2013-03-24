package Reactive::Observable;

use Moose;
use Reactive::Scheduler::Coro;
use aliased 'Reactive::Observer';
use aliased 'Reactive::Observable::FromClosure';
use aliased 'Reactive::Observable::Generate';
use aliased 'Reactive::Observable::FromStdIn';
use aliased 'Reactive::Observable::Map';
use aliased 'Reactive::Observable::Grep';
use aliased 'Reactive::Observable::Count';
use aliased 'Reactive::Observable::Take';
use aliased 'Reactive::Observable::DistinctChanges';
use aliased 'Reactive::Observable::Buffer';
use aliased 'Reactive::Observable::Push';
use aliased 'Reactive::Observable::Merge';
use aliased 'Reactive::Observable::CombineLatest';

has scheduler => (is => 'ro', lazy_build => 1, handles =>
                 [qw(schedule_recursive now)]);

sub _build_scheduler { Reactive::Scheduler::Coro->new }

# subscribe with a set of handlers
sub subscribe {
    my ($self, %handlers) = @_;
    $handlers{$_} ||= sub {} foreach qw(on_next on_error on_complete);
    my $observer = Observer->new(handlers => {%handlers});
    return $self->subscribe_observer($observer);
}

# subscribe with an observer
sub subscribe_observer {
    my ($self, $observer) = @_;
    return $self->run($observer);
}

sub maybe_scheduler($) { $_[0]? (scheduler => $_[0]): () }

# creating --------------------------------------------------------------------

sub once {
    my ($class, $value) = @_;
    return FromClosure->new(on_subscribe => sub {
        my $observer = shift;
        $observer->on_next($value);
        $observer->on_complete;
        return undef;
    });
}

sub range {
    my ($class, $from, $size) = @_;
    return FromClosure->new(on_subscribe => sub {
        my $observer = shift;
        my $i    = $from;
        my $to   = $from + $size;
        while ($i < $to) { $observer->on_next($i++) }
        $observer->on_complete;
        return undef;
    });
}

sub empty {
    my ($class) = @_;
    return FromClosure->new(on_subscribe => sub {
        my $observer = shift;
        $observer->on_complete;
        return undef;
    });
}

sub never {
    my ($class) = @_;
    return FromClosure->new(on_subscribe => sub {
        return undef;
    });
}

sub throw {
    my ($class, $err) = @_;
    return FromClosure->new(on_subscribe => sub {
        my $observer = shift;
        $observer->on_error($err);
        return undef;
    });
}

sub from_list {
    my ($class, @list) = @_;
    return FromClosure->new(on_subscribe => sub {
        my $observer = shift;
        $observer->on_next($_) for @list;
        $observer->on_complete;
        return undef;
    });
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

sub from_stdin { return FromStdIn->new }

# projections ------------------------------------------------------------------

sub map {
    my ($self, $projection) = @_;
    return Map->new(wrap => $self, projection => $projection);
}

sub grep {
    my ($self, $predicate) = @_;
    return Grep->new(wrap => $self, predicate => $predicate);
}

sub count {
    my ($self) = @_;
    return Count->new(wrap => $self);
}

sub take {
    my ($self, $max) = @_;
    return Take->new(wrap => $self, max => $max);
}

sub unshift {
    my ($self, $thing, @rest) = @_;
    my $ref = ref $thing;
    my $observable = ($ref && $thing->isa(__PACKAGE__))?
        $thing:
        ref($self)->from_list($thing, @rest);
    # unshift is reverse of push
    return Push->new(o1 => $observable, o2 => $self);
}

sub distinct_changes {
    my ($self) = @_;
    return DistinctChanges->new(wrap => $self);
}

sub buffer {
    my ($self, $size, $skip) = @_;
    return Buffer->new(
        wrap => $self,
        size => $size,
        skip => $skip || $size,
    );
}

# catamorphisms ----------------------------------------------------------------

# joining ----------------------------------------------------------------------

sub push {
    my ($self, $observable) = @_;
    return Push->new(o1 => $self, o2 => $observable);
}

sub merge {
    my ($self, $observable) = @_;
    return Merge->new(o1 => $self, o2 => $observable);
}

sub combine_latest {
    my ($self, $observable) = @_;
    return CombineLatest->new(o1 => $self, o2 => $observable);
}

1;


