use strict;
use warnings;

use lib './t/lib';

use Test::More;
use Reactive;
use Reactive::Test::ObservableFixture;

subtest 'no timeout' => sub {
    my $s = subscribe Observable->interval(100, $scheduler)
                                ->take(3)
                                ->timeout(102, $scheduler);
    advance_and_check_event_counts
        [   1 => 0   ],
        [ 100 => 1, 0],
        [ 100 => 2, 0],
        [ 100 => 3, 1];
};
restart;

subtest 'timeout' => sub {
    my $s = subscribe Observable->interval(100, $scheduler)
                                ->take(3)
                                ->timeout(
                                    50,
                                    Observable->once(444),
                                    $scheduler);
    advance_and_check_event_counts
        [   1 => 0   ],
        [  50 => 1, 1];
};
restart;

subtest 'timeout with delay' => sub {
    my $s = subscribe Observable->interval(100, $scheduler)
                                ->take(3)
                                ->timeout(
                                    50,
                                    Observable->timer(20, $scheduler),
                                    $scheduler);
    advance_and_check_event_counts
        [   1 => 0   ],
        [  50 => 0   ],
        [  80 => 1, 1];
};
restart;

done_testing;

