use strict;
use warnings;

use lib './t/lib';

use Test::More;
use Reactive;
use Reactive::Test::ObservableFixture;

subtest '3 chained notifications' => sub {
    my $s = subscribe
        Observable->timer(100, $scheduler)
                  ->map(3)
                  ->expand(sub{
                        my $value = shift() - 1;
                        $value? Observable->timer(100, $scheduler)
                                          ->map($value)
                              : Observable->empty;
                    });
    advance_and_check_event_counts
        [   1 => 0   ],
        [ 100 => 1   ],
        [ 100 => 2   ],
        [ 100 => 3, 1];
};
restart;

subtest 'correct disposal' => sub {
    my $s = subscribe
        Observable->interval(100, $scheduler)
                  ->count
                  ->expand(sub{ Observable->empty })
                  ->take(3);

    advance_and_check_event_count 301 => 3, 1;
    is_deeply \@next, [1, 2, 3];
};
restart;

done_testing;

