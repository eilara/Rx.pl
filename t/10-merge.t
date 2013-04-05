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

subtest 'merge observables that complete on subscription' => sub {
    my $s = subscribe 
              Observable->once(1)
     ->merge( Observable->once(2) );

    is_deeply \@next    , [1, 2], 'order is preserved';
    is_deeply \@complete, [1   ], '1 complete';
};
restart;

subtest 'merge with observable that completes on subscription' => sub {
    my $s = subscribe 
              Observable->once(1)
     ->merge( Observable->timer(100 ,$scheduler) );

    advance_and_check_event_counts
        [   0 => 1   ],
        [ 101 => 2, 1];
};
restart;

subtest 'merge with no args is merge of observable of observables' => sub {
    my $s = subscribe Observable->from_list(1, 2, 3)
                                ->map(sub{ Observable->once(2 * $_) })
                                ->merge;
    advance_and_check_event_count 0 => 3, 1;
    is_deeply \@next, [2, 4, 6], 'observables flattened';
};
restart;

subtest 'merge on class is merge of list of observables' => sub {
    my $s = subscribe Observable->merge(
        Observable->from_list(1, 2, 3),
        Observable->timer(1000, $scheduler),
        Observable->timer(2000, $scheduler),
    );
    advance_and_check_event_counts
        [   0 => 3   ],
        [1001 => 4   ],
        [1000 => 5, 1];
};
restart;

subtest 'also works on array ref' => sub {
    my $s = subscribe Observable->merge([
        Observable->from_list(1, 2, 3),
        Observable->timer(1000, $scheduler),
        Observable->timer(2000, $scheduler),
    ]);
    advance_and_check_event_counts
        [   0 => 3   ],
        [1001 => 4   ],
        [1000 => 5, 1];
};
restart;

done_testing;

