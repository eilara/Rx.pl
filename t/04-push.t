use strict;
use warnings;

use lib './t/lib';

use Test::More;
use Reactive;
use Reactive::Test::ObservableFixture;


subtest 'simple push' => sub {
    my $o1  = Observable->timer(2000, $scheduler);
    my $o2  = Observable->timer(5000, $scheduler);
    my $iut = $o1->push($o2);
    my $s   = subscribe $iut;

    advance_and_check_event_counts
        [1001 => 0   ],
        [1000 => 1   ],
        [1000 => 1   ],
        [2000 => 1   ],
        [2000 => 2, 1],
        [9000 => 2, 1];
};
restart;

subtest 'unsubscribe on push subscription' => sub {
    my $o1  = Observable->interval(100, $scheduler);
    my $o2  = Observable->interval(222, $scheduler);
    my $iut = $o1->push($o2);
    my $s   = subscribe $iut;

    advance_and_check_event_counts
        [  99 => 0],
        [   2 => 1],
        [ 100 => 2];

    undef $s;

    advance_and_check_event_count 1000 => 2;
};
restart;

subtest 'push to stream that completes on subscribe' => sub {
    my $o1  = Observable->once(111);
    my $o2  = Observable->timer(100, $scheduler);
    my $iut = $o1->push($o2);
    my $s   = subscribe $iut;

    advance_and_check_event_counts
        [  1 => 1   ],
        [100 => 2, 1];
};
restart;

done_testing;

