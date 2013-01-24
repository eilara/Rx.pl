use strict;
use warnings;
use Test::More;
use Reactive;
use Reactive::Test::ObservableFixture;

my $iut = Observable->interval(1000, $scheduler)
                    ->take(3);

my $s = subscribe $iut;

advance_and_check_event_counts
    [1001 => 1   ],
    [1000 => 2   ],
    [1000 => 3, 1],
    [1000 => 3, 1],
    [1000 => 3, 1];

done_testing;

