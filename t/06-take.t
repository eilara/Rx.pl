use strict;
use warnings;
use Test::More;
use Reactive;
use Reactive::Test::ObservableFixture;

subtest 'take from interval' => sub {
    my $s = subscribe Observable->interval(1000, $scheduler)
                                ->take(3);
    advance_and_check_event_counts
        [1001 => 1   ],
        [1000 => 2   ],
        [1000 => 3, 1],
        [1000 => 3, 1],
        [1000 => 3, 1];
};
restart;

subtest 'take 1 of 1' => sub {
    my $s = subscribe Observable->once(1)
                                ->take(1);
    advance_and_check_event_count 1 => 1, 1;
};
restart;

done_testing;
