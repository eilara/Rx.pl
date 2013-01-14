use strict;
use warnings;
use Test::More;
use Test::Builder;
use Coro;
use aliased 'DateTime::Duration';
use aliased 'Rx::Test::Scheduler::Virtual' => 'Scheduler';
use Rx;

my $scheduler = Scheduler->new;

my (@next, @complete, @error);

sub are_events($$;$$) {
    my ($advance_by, $next, $complete, $error) = @_;
    $complete ||= 0;
    $error    ||= 0;
    $scheduler->advance_by($advance_by) if $advance_by;
    my $now = $scheduler->now;
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    is scalar @next    , $next    , "\@next     at t=$now";
    is scalar @complete, $complete, "\@complete at t=$now";
    is scalar @error   , $error   , "\@error    at t=$now";
}

my $o = Rx->timer(Duration->new(seconds => 2), $scheduler);

my $s = $o->subscribe(
    on_next     => sub { push @next    , $_ },
    on_complete => sub { push @complete, 1  },
    on_error    => sub { push @error   , $_ },
);
cede;

are_events 0000 => 0;
are_events 1000 => 0;
are_events 1001 => 1, 1;

is $next[0], 1, '1st value';

are_events 8000 => 1, 1;

done_testing;

