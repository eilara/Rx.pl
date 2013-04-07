package Reactive::Observable;

use Moose;
use Reactive::Scheduler::Coro;
use AnyEvent;
use Reactive::Disposable::Empty;
use aliased 'Reactive::Observer';
use aliased 'Reactive::Observable::FromClosure';
use aliased 'Reactive::Observable::Subject';
use aliased 'Reactive::Observable::Connectable';
use aliased 'Reactive::Observable::Generate';
use aliased 'Reactive::Observable::FromStdIn';
use aliased 'Reactive::Observable::Map';
use aliased 'Reactive::Observable::Expand';
use aliased 'Reactive::Observable::Grep';
use aliased 'Reactive::Observable::Count';
use aliased 'Reactive::Observable::Take';
use aliased 'Reactive::Observable::TakeLast';
use aliased 'Reactive::Observable::Skip';
use aliased 'Reactive::Observable::DistinctChanges';
use aliased 'Reactive::Observable::Buffer';
use aliased 'Reactive::Observable::Push';
use aliased 'Reactive::Observable::Merge';
use aliased 'Reactive::Observable::MergeNotifications';
use aliased 'Reactive::Observable::MultiMerge';
use aliased 'Reactive::Observable::CombineLatest';
use aliased 'Reactive::Observable::Delay';
use aliased 'Reactive::Observable::Do';

sub empty_disposable() { Reactive::Disposable::Empty->new }

# when you subscribe forever, by calling subscribe()
# in void context, we save the subscription forever
# right here
my @Global_Subscriptions = ();

has scheduler => (is => 'ro', lazy_build => 1, handles =>
                 [qw(schedule_periodic schedule_once now)]);

sub _build_scheduler { Reactive::Scheduler::Coro->new }

# subscribe with a set of handlers
sub subscribe {
    my ($self, @handlers) = @_;
    my $is_void_context = !defined(wantarray);
    my $handlers = $self->sugarize_handlers(@handlers);
    my $observer = Observer->new(handlers => $handlers);
    my $disposable = $self->subscribe_observer($observer);
    push(@Global_Subscriptions, $disposable) if $is_void_context;
    return $disposable;
}

# subscribe with an observer
sub subscribe_observer {
    my ($self, $observer) = @_;
    return $self->run($observer);
}

sub sugarize_handlers {    
    my ($self, @handlers) = @_;
    # sugar - if one sub only, then it is on_next handler
    my %handlers = (@handlers == 1)? (on_next => $handlers[0]): @handlers;
    # sugar - missing handlers are empty subs
    $handlers{$_} ||= sub {} foreach qw(on_next on_error on_complete);
    return {%handlers};
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

sub publish {
    my $self = shift;
    return Connectable->new(wrap => $self);
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

sub let {
    my ($self, $projection) = @_;
    return $projection->($self);
}

sub map {
    my ($self, $thing) = @_;
    # sugar: map to value is sub which returns value
    my $projection = ref $thing eq 'CODE'? $thing: sub { $thing };
    return Map->new(wrap => $self, projection => $projection);
}

sub expand {
    my ($self, $projection) = @_;
    return Expand->new(wrap => $self, projection => $projection);
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
    my ($self, $count) = @_;
    return Take->new(wrap => $self, count => $count);
}

sub take_last {
    my ($self, $count) = @_;
    return TakeLast->new(wrap => $self, count => $count);
}

sub skip {
    my ($self, $count) = @_;
    return Skip->new(wrap => $self, count => $count);
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
    my ($self, @observables) = @_;
    # merge on class is multi merge of N observables in a list
    return MultiMerge->new(observables => (
        # sugar - observables can be given as list or array ref
        ref($observables[0]) eq 'ARRAY'?
            $observables[0]: [@observables]
    )) unless ref $self;
    # merge with no args is merge of observable of observables
    my $observable = $observables[0];
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

# side-effects -----------------------------------------------------------------

sub do {
    my ($self, $action) = @_;
    return Do->new(wrap => $self, action => $action);
}

# blocking ---------------------------------------------------------------------

sub foreach {
    my ($self, @handlers) = @_;
    my $cv = AnyEvent->condvar;
    my $handlers = $self->sugarize_handlers(@handlers);
    my $disposable = $self->subscribe(
        on_next => sub {
            my ($value) = @_;
            local $_ = $value;
            $handlers->{on_next}->($_);
        },
        on_complete => sub {
            $handlers->{on_complete}->();
            $cv->send;
        },
        on_error => sub {
            my ($error) = @_;
            local $_ = $error;
            $handlers->{on_error}->($_);
            $cv->send;
        },
    );
    $cv->recv;
    return undef;
}


1;


