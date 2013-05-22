use strict;
use warnings;

use lib './t/lib';

use Test::More;
use Reactive;
use Reactive::Test::ObservableFixture;

subtest 'simple repeat' => sub {
    my $s = subscribe Observable->from_list(1, 2)
                                ->repeat(3);

    advance_and_check_event_count 0 => 6, 1;
    is_deeply \@next, [1, 2, 1, 2, 1, 2];
};
restart;

subtest 'infinite repeat with take' => sub {
    # must do timer(0) instead of once() because otherwise
    # we would have infinite recursion with notifications
    my $s = subscribe Observable->timer(0, $scheduler)
                                ->map(1)
                                ->repeat
                                ->take(4);

    advance_and_check_event_count 1 => 4, 1;
    is_deeply \@next, [1, 1, 1, 1];
};
restart;

done_testing;
