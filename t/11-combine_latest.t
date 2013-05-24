use strict;
use warnings;

use lib './t/lib';

use Test::More;
use Reactive;
use Reactive::Test::ObservableFixture;

my $fire_at = sub {
    my ($t, $v) = @_;
    Observable->timer($t, $scheduler)
              ->map($v);
};

#              o1: 1--------2----3------->
#              o2: ----4--------------5-->
#  combine_latest: ---1:4--2:4--3:4--3:5->

my $o1  =        $fire_at->(1000, 1)
          ->push($fire_at->(1000, 2))
          ->push($fire_at->(1000, 3))
          ->push($fire_at->(1000, 0)); # will not arrive

my $o2  =        $fire_at->(1100, 4)
          ->push($fire_at->(2000, 5));

my $s = subscribe $o1->combine_latest($o2);

advance_and_check_event_counts
    [1001 => 0   ],
    [ 100 => 1   ],
    [1000 => 2   ],
    [ 900 => 3,  ],
    [ 100 => 4, 1];

is_deeply $next[0], [1, 4], '1st event';
is_deeply $next[1], [2, 4], '2nd event';
is_deeply $next[3], [3, 5], 'last event';

done_testing;

