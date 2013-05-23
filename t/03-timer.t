use strict;
use warnings;

use Test::More;

use lib './t/lib';

use Reactive;
use Reactive::Test::ObservableFixture;

my $iut = Observable->timer(2000, $scheduler);

my $s = subscribe $iut;

advance_and_check_event_counts
    [   0 => 0   ],
    [1000 => 0   ],
    [1001 => 1, 1],
    [2000 => 1, 1];

is $next[0], 1, '1st value';

advance_and_check_event_count 8000 => 1, 1;

done_testing;

