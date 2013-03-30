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
        [1001 => 0],
        [ 600 => 1],
        [ 400 => 2],
        [ 998 => 2],
        [   2 => 3],
        [ 200 => 4];
};
restart;

subtest 'completes when all merged observables complete' => sub {
    my $s = subscribe 
              Observable->timer(2000, $scheduler)
     ->merge( Observable->timer(3000, $scheduler) );

    advance_and_check_event_counts
        [1001 => 0   ],
        [1000 => 1   ],
        [1000 => 2, 1];
};
restart;

subtest 'error on child causes error on parent' => sub {
    my $s = subscribe 
        Observable->interval(100, $scheduler)
                  ->merge( Observable->timer(150, $scheduler)
                                     ->push(Observable->throw('Error Foo'))
                         );

    advance_and_check_event_counts
        [   1 => 0      ],
        [ 100 => 1      ],
        [  50 => 2, 0, 1],
        [ 100 => 2, 0, 1];
};
restart;

done_testing;

