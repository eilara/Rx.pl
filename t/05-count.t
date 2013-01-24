use strict;
use warnings;
use Test::More;
use Reactive;
use Reactive::Test::ObservableFixture;

my $iut = Observable->interval(1000, $scheduler)
                    ->count;

my $s = subscribe $iut;

advance_and_check_event_counts
    [1001 => 1],
    [1000 => 2];

is $next[-1], 2, '2nd event';

advance_and_check_event_count 5001 => 7;
is $next[-1], 7, '7th event';

done_testing;

