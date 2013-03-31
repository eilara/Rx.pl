package Reactive::Observable;

use Moose;
use Reactive::Scheduler::Coro;
use Reactive::Disposable::Empty;
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
use aliased 'Reactive::Observable::MergeNotifications';
use aliased 'Reactive::Observable::CombineLatest';
use aliased 'Reactive::Observable::Subject';
use aliased 'Reactive::Observable::Delay';

sub empty_disposable() { Reactive::Disposable::Empty->new }

# when you subscribe forever, by calling subscribe()
# in void context, we save the subscription forever
# right here
my @Global_Subscriptions = ();

has scheduler => (is => 'ro', lazy_build => 1, handles =>
                 [qw(schedule_recursive schedule_once now)]);

sub _build_scheduler { Reactive::Scheduler::Coro->new }

# subscribe with a set of handlers
sub subscribe {
    my ($self, @handlers) = @_;
    my $is_void_context = !defined(wantarray);
    # sugar- if one sub only, then it is on_next handler
    my %handlers = (@handlers == 1)? (on_next => $handlers[0]): @handlers;
    $handlers{$_} ||= sub {} foreach qw(on_next on_error on_complete);
    my $observer = Observer->new(handlers => {%handlers});
    my $disposable = $self->subscribe_observer($observer);
    push(@Global_Subscriptions, $disposable) if $is_void_context;
    return $disposable;
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
        return empty_disposable;
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
        return empty_disposable;
    });
}

sub empty {
    my ($class) = @_;
    return FromClosure->new(on_subscribe => sub {
        my $observer = shift;
        $observer->on_complete;
        return empty_disposable;
    });
}

sub never {
    my ($class) = @_;
    return FromClosure->new(on_subscribe => sub {
        return empty_disposable;
    });
}

sub throw {
    my ($class, $err) = @_;
    return FromClosure->new(on_subscribe => sub {
        my $observer = shift;
        $observer->on_error($err);
        return empty_disposable;
    });
}

sub from_list {
    my ($class, @list) = @_;
    return FromClosure->new(on_subscribe => sub {
        my $observer = shift;
        $observer->on_next($_) for @list;
        $observer->on_complete;
        return empty_disposable;
    });
}

sub subject {
    my $class = shift;
    return Subject->new;
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


sub unshift {
    my ($self, $thing, @rest) = @_;
    my $ref = ref $thing;
    my $observable = ($ref && UNIVERSAL::isa($thing, __PACKAGE__))?
        $thing:
        ref($self)->from_list($thing, @rest);
    # unshift is reverse of push
    return Push->new(o1 => $observable, o2 => $self);
}

sub merge {
    my ($self, $observable) = @_;
    # merge with no args is merge of observable of observables
    return $observable?
        Merge->new(o1 => $self, o2 => $observable):
        MergeNotifications->new(wrap => $self);
}

sub combine_latest {
    my ($self, $observable) = @_;
    return CombineLatest->new(o1 => $self, o2 => $observable);
}

# time related -----------------------------------------------------------------

sub delay {
    my ($self, $delay, $scheduler) = @_;
    return Delay->new(
        wrap  => $self,
        delay => $delay,
        maybe_scheduler $scheduler
    );
}

1;


