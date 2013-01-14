use strict;
use warnings;
use Test::More;
use Coro;
use aliased 'DateTime::Duration';
use aliased 'Rx::Scheduler::Virtual' => 'IUT';
use Rx;

my $scheduler = IUT->new;

my $o = Rx->interval(Duration->new(seconds => 0.4), $scheduler);

my (@next, @complete, @error);

my $s = $o->subscribe(
    on_next     => sub { push @next    , $_ },
    on_complete => sub { push @complete, 1  },
    on_error    => sub { push @error   , $_ },
);
cede;

is scalar @next    , 0, '@next     at t=0';
is scalar @complete, 0, '@complete at t=0';
is scalar @error   , 0, '@error    at t=0';

$scheduler->advance_by(300);
is scalar @next    , 0, '@next     at t=300';
is scalar @complete, 0, '@complete at t=300';
is scalar @error   , 0, '@error    at t=300';

$scheduler->advance_by(200);
is scalar @next    , 1, '@next     at t=500';
is scalar @complete, 0, '@complete at t=500';
is scalar @error   , 0, '@error    at t=500';
is $next[0], 0, '1st value';

$scheduler->advance_by(400);
is scalar @next    , 2, '@next     at t=900';
is scalar @complete, 0, '@complete at t=900';
is scalar @error   , 0, '@error    at t=900';
is $next[1], 1, '2nd value';

$scheduler->advance_by(1600);
is scalar @next    , 6, '@next     at t=2500';
is scalar @complete, 0, '@complete at t=2500';
is scalar @error   , 0, '@error    at t=2500';

$s = undef;

$scheduler->advance_by(2000);
is scalar @next    , 6, '@next     at t=4500';
is scalar @complete, 0, '@complete at t=4500';
is scalar @error   , 0, '@error    at t=4500';

done_testing;
