use strict;
use warnings;
use Test::More;
use Reactive;
use Reactive::Test::ObservableFixture;

subtest 'merge 2 timers and interval' => sub {
    my $s = subscribe 
              Observable->timer(2000, $scheduler)
     ->merge( Observable->timer(3000, $scheduler) )
     ->merge( Observable->interval(1600, $scheduler) );

    advance_and_check_event_counts
        [1001 => 0   ],
        [ 600 => 1   ],
        [ 400 => 2   ],
        [ 998 => 2   ],
        [   2 => 3   ],
        [ 200 => 4   ];
};
restart;

done_testing;

