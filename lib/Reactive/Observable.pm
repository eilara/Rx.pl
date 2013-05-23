package Reactive::Observable;

use Moose;
use Scalar::Util qw(weaken);
use Reactive::Scheduler::Coro;
use AnyEvent;
use Reactive::Disposable::Empty;
use aliased 'Reactive::Observer';
use aliased 'Reactive::Observable::FromClosure';
use aliased 'Reactive::Observable::Subject';
use aliased 'Reactive::Observable::ReplaySubject';
use aliased 'Reactive::Observable::Connectable';
use aliased 'Reactive::Observable::Materialize';
use aliased 'Reactive::Observable::Defer';
use aliased 'Reactive::Observable::Generate';
use aliased 'Reactive::Observable::FromStdIn';
use aliased 'Reactive::Observable::FromCursesStdIn';
use aliased 'Reactive::Observable::Map';
use aliased 'Reactive::Observable::Scan';
use aliased 'Reactive::Observable::Expand';
use aliased 'Reactive::Observable::Grep';
use aliased 'Reactive::Observable::Catch';
use aliased 'Reactive::Observable::Count';
use aliased 'Reactive::Observable::Take';
use aliased 'Reactive::Observable::TakeLast';
use aliased 'Reactive::Observable::TakeUntilPredicate';
use aliased 'Reactive::Observable::TakeUntilObservable';
use aliased 'Reactive::Observable::TakeWhilePredicate';
use aliased 'Reactive::Observable::Skip';
use aliased 'Reactive::Observable::SkipUntilObservable';
use aliased 'Reactive::Observable::Repeat';
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

=head1 METHODS

=head2 empty_disposable()

For internal use.

=head2 $self->subscribe(@handlers)

Subscribe to the handlers - B<TODO> document better.

=cut

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

=head2 $self->subscribe_observer($observer)

Subscribe to C<$observer> .

=cut

# subscribe with an observer
sub subscribe_observer {
    my ($self, $observer) = @_;
    return $self->run($observer);
}

=head2 $self->sugarize_handlers(@handlers)

Sugarize the handlers. If only one is present - it is on_next. Else
it is treated as hash with C<'on_next'> , C<'on_error'>,
C<'on_complete'> that can be empty.

=cut

sub sugarize_handlers {    
    my ($self, @handlers) = @_;
    # sugar - if one sub only, then it is on_next handler
    my %handlers = (@handlers == 1)? (on_next => $handlers[0]): @handlers;
    # sugar - missing handlers are empty subs
    $handlers{$_} ||= sub {} foreach qw(on_next on_error on_complete);
    return {%handlers};
}

=head2 maybe_scheduler(foo)

Internal use.

=cut

sub maybe_scheduler($) { $_[0]? (scheduler => $_[0]): () }

# creating --------------------------------------------------------------------

=head2 $class->once($value)

Emit the value once.

=cut

sub once {
    my ($class, $value) = @_;
    return FromClosure->new(on_subscribe => sub {
        my $observer = shift;
        $observer->on_next($value);
        $observer->on_complete;
        return empty_disposable;
    });
}

=head2 $class->range($from, $size)

Emit $size integers starting from $from .

=cut

sub range {
    my ($class, $from, $size) = @_;
    return FromClosure->new(on_subscribe => sub {
        my $observer = shift;
        my $i  = $from;
        my $to = $from + $size;
        while ($i < $to) { $observer->on_next($i++) }
        $observer->on_complete;
        return empty_disposable;
    });
}

=head2 $class->empty()

The empty event list.

=cut

sub empty {
    my ($class) = @_;
    return FromClosure->new(on_subscribe => sub {
        my $observer = shift;
        $observer->on_complete;
        return empty_disposable;
    });
}

=head2 $class->never()

Never should happen.

B<TODO> document better.

=cut

sub never {
    my ($class) = @_;
    return FromClosure->new(on_subscribe => sub {
        return empty_disposable;
    });
}

=head2 $class->throw()

Throw any event into an on_error.

=cut

sub throw {
    my ($class, $err) = @_;
    return FromClosure->new(on_subscribe => sub {
        my $observer = shift;
        $observer->on_error($err);
        return empty_disposable;
    });
}

=head2 $class->from_list(@list)

Create a stream from a list.

=cut

sub from_list {
    my ($class, @list) = @_;
    return FromClosure->new(on_subscribe => sub {
        my $observer = shift;
        $observer->on_next($_) for @list;
        $observer->on_complete;
        return empty_disposable;
    });
}

=head2 $class->subject()

B<Internal use>

=cut

sub subject     { Subject->new }

=head2 $class->publish()

B<Internal use>

=cut

sub publish     { Connectable->new(wrap => shift) }

=head2 $class->materialize()

B<Internal use>

=cut

sub materialize { Materialize->new(wrap => shift) }

=head2 $class->memoize()

B<TODO> document.

=cut

sub memoize {
    my $self = shift;
    return Connectable->new(
        wrap    => $self->materialize,
        subject => ReplaySubject->new,
    )->connect;
}

=head2 $class->defer()

B<TODO> document.

=cut

sub defer {
    my ($class, $projection) = @_;
    return Defer->new(projection => $projection);
}

# from time --------------------------------------------------------------------

=head2 $class->interval($duration, $scheduler)

Write an incremented integer (starting from 0) every C<$duration>, with
an optional scheduler as $scheduler .

=cut

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

=head2 $class->timer($duration, $scheduler)

Generate an event every C<$duration>, with an optional scheduler as
$scheduler .

=cut

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

=head2 $class->from_stdin()

An event of lines from standard input.

=cut

sub from_stdin { return FromStdIn->new }

=head2 $class->from_curses_stdin()

An event of lines from L<Curses> standard input.

=cut


sub from_curses_stdin { return FromCursesStdIn->new }

# projections ------------------------------------------------------------------

=head2 $self->let($projection_cb)

Call $projection_cb with one self.

=cut

sub let {
    my ($self, $projection) = @_;
    local $_ = $self;
    return $projection->($self);
}

=head2 $class->map([ $thing_cb | $thing_datum])

Map the even using $thing_cb or if it's not a callback convert it all
to $thing_datum .

=cut

sub map {
    my ($self, $thing) = @_;
    # sugar: map to value is sub which returns value
    my $projection = ref $thing eq 'CODE'? $thing: sub { $thing };
    return Map->new(wrap => $self, projection => $projection);
}

=head2 $class->scan($seed, $projection)

B<TODO:> Document. @eilara - I am looking at you.

=cut

sub scan {
    my ($self, $seed, $projection) = @_;
    return Scan->new
        (wrap => $self, seed => $seed, projection => $projection);
}

=head2 $class->expand($seed, $projection)

B<TODO:> Document. @eilara - I am looking at you.

=cut

sub expand {
    my ($self, $projection) = @_;
    return Expand->new(wrap => $self, projection => $projection);
}

=head2 $self->grep($filter_cb)

Filters the stream using $filter_cb .

=cut

sub grep {
    my ($self, $predicate) = @_;
    return Grep->new(wrap => $self, predicate => $predicate);
}

=head2 $class->catch($thing)

B<TODO:> Document. @eilara - I am looking at you.

=cut

sub catch {
    my ($self, $thing) = @_;
    # sugar - if projection is observable, we will wrap it in a sub
    my $projection = UNIVERSAL::isa($thing, __PACKAGE__)?
        sub{ $thing }: $thing;
    return Catch->new(wrap => $self, projection => $projection);
}

=head2 $self->count()

Returns a stream with the count of events.

=cut

sub count {
    my ($self) = @_;
    return Count->new(wrap => $self);
}

=head2 $self->take($count)

Take the first $count items from the stream.

=cut

sub take {
    my ($self, $count) = @_;
    return Take->new(wrap => $self, _count => $count);
}

=head2 $self->take_until([$thing_cb | $thing])

Take until the $thing_cb CALLBACK returns true or is equal to $thing .

=cut

sub take_until {
    my ($self, $thing) = @_;
    return ref $thing eq 'CODE'?
        TakeUntilPredicate->new(wrap => $self, predicate => $thing):
        TakeUntilObservable->new(o1 => $self, o2 => $thing);
}

=head2 $self->take_while($predicate_cb)

Take while $predicate_cb returns true.

=cut

sub take_while {
    my ($self, $predicate) = @_;
    return TakeWhilePredicate->new(wrap => $self, predicate => $predicate);
}

=head2 $self->take_last($count)

Take last $count items from the stream.

=cut

sub take_last {
    my ($self, $count) = @_;
    return TakeLast->new(wrap => $self, _count => $count);
}

=head2 $self->skip($count)

Skip the first $count items from the stream.

=cut

sub skip {
    my ($self, $count) = @_;
    return Skip->new(wrap => $self, _count => $count);
}

=head2 $self->skip_until($thing_cb)

Skip until it hits $thing_cb->($_).

=cut

sub skip_until {
    my ($self, $thing) = @_;
    return ref $thing eq 'CODE'
        ? die 'TODO'
        : SkipUntilObservable->new(o1 => $self, o2 => $thing);
}

=head2 $self->repeat($count)

Repeat each element in the stream $count times.

=cut

sub repeat {
    my ($self, $count) = @_;
    return Repeat->new(wrap => $self, _count => $count);
}

=head2 $self->retry($count)

Retry $count times upon an error.

=cut

sub retry {
    my ($self, $count) = @_;
    return $self->catch(sub{ my $error = shift;
                             (!defined($count) || $count > 0)?
                                 $self->retry($count? ($count-1): undef):
                                 __PACKAGE__->throw($error) })
}

=head2 $self->distinct_changes()

Like uniq() .

=cut

sub distinct_changes {
    my ($self) = @_;
    return DistinctChanges->new(wrap => $self);
}

=head2 $self->buffer($size, $skip)

B<TODO:> Document. @eilara - I am looking at you.

=cut

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

=head2 $self->push($observable)

Append $observable at the end of this one.

=cut

sub push {
    my ($self, $observable) = @_;
    return Push->new(o1 => $self, o2 => $observable);
}

=head2 $self->unshift($thing, @rest)

Prepend $thing (if it's an observable) at the end of this one. If it's
not use L<from_list> on $thing and @rest and use that.

=cut

sub unshift {
    my ($self, $thing, @rest) = @_;
    my $ref = ref $thing;
    my $observable = ($ref && UNIVERSAL::isa($thing, __PACKAGE__)) ?
        $thing :
        ref($self)->from_list($thing, @rest);
    # unshift is reverse of push
    return Push->new(o1 => $observable, o2 => $self);
}

=head2 $self->merge(@observable)

Merge the observables.

=cut

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

=head2 $self->combine_latest($observable)

B<TODO:> Document. @eilara - I am looking at you.

=cut

sub combine_latest {
    my ($self, $observable) = @_;
    return CombineLatest->new(o1 => $self, o2 => $observable);
}

# time related -----------------------------------------------------------------

=head2 $self->delay($delay, $scheduler)

Delay with time $delay and optional scheduler $scheduler.

=cut

sub delay {
    my ($self, $delay, $scheduler) = @_;
    return Delay->new(
        wrap  => $self,
        delay => $delay,
        maybe_scheduler $scheduler
    );
}

# side-effects -----------------------------------------------------------------

=head2 $self->do($delay, $action_cb)

Perform $action_cb on the events.

=cut

sub do {
    my ($self, $action) = @_;
    return Do->new(wrap => $self, action => $action);
}

# blocking ---------------------------------------------------------------------

=head2 $self->foreach(@handlers)

Pass every event in the stream through @handlers - see
L<sugarize_handlers> .

    $stream->foreach(on_next => sub { say $_; });

=cut

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


