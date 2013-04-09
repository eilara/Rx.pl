use strict;
use warnings;
use Test::More;
use Reactive;
use Reactive::Test::ObservableFixture;

subtest 'no retries needed' => sub {
    my $s = subscribe Observable->once(1)->retry(3);
    advance_and_check_event_count 0 => 1, 1, 0;
};
restart;

subtest '3 retry fails' => sub {
    my $s = subscribe Observable->throw('X')
                                ->retry(3);
    advance_and_check_event_count 0 => 0, 0, 1;
    is_deeply \@error, ['X'];
};
restart;

subtest '4th retry OK' => sub {
    my $i;
    my $s = subscribe Observable->defer(sub{
                                      ++$i == 4? Observable->once(999)
                                               : Observable->throw("X$i") })
                                ->retry(3);
    advance_and_check_event_count 0 => 1, 1, 0;
    is_deeply \@next, [999];
};
restart;

done_testing;
