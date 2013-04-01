use strict;
use warnings;
use Test::More;
use Reactive;
use Reactive::Test::ObservableFixture;

subtest 'on_next delayed' => sub {
    my $s = subscribe Observable->timer(100, $scheduler)
                                ->merge(Observable->never)
                                ->delay( 10, $scheduler);
    advance_and_check_event_counts
        [   1 => 0   ],
        [ 100 => 0, 0],
        [  10 => 1, 0];
};
restart;

subtest 'only on_next is delayed' => sub {
    my $s = subscribe Observable->timer(100, $scheduler)
                                ->delay( 10, $scheduler);
    advance_and_check_event_counts
        [   1 => 0   ],
        [ 100 => 0, 1];
};
restart;

subtest 'delay with complete on subscription' => sub {
    my $s = subscribe Observable->once(123)
                                ->delay( 10, $scheduler);
    advance_and_check_event_counts
        [ 1 => 0, 1],
        [10 => 0, 1];
};
restart;

subtest 'delay with error on subscription' => sub {
    my $s = subscribe Observable->throw('Error Quux')
                                ->delay( 10, $scheduler);
    advance_and_check_event_counts
        [ 1 => 0, 0, 1],
        [10 => 0, 0, 1];
};
restart;

done_testing;

