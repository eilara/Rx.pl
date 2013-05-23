use strict;
use warnings;

use lib './t/lib';

use Test::More;
use Reactive;
use Reactive::Test::ObservableFixture;

my $iut = Observable->interval(1000, $scheduler)
                    ->buffer(2, 1);

my $s = subscribe $iut;

advance_and_check_event_counts
    [ 101 => 0],
    [ 900 => 0],
    [1000 => 1],
    [1000 => 2],
    [1000 => 3];

is_deeply $next[0], [0, 1], '1st value';
is_deeply $next[2], [2, 3], 'last value';

done_testing;

