use strict;
use warnings;
use Test::More;
use Reactive;
use Reactive::Test::ObservableFixture;

subtest 'clean all errors' => sub {
    my $s = subscribe Observable->throw('X')
                                ->catch(Observable->empty)
                                ->repeat(3);
    advance_and_check_event_count 0 => 0, 1, 0;
};
restart;

subtest 'transform error into message and repeat' => sub {
    my $s = subscribe Observable->throw('X')
                                ->catch(sub{ Observable->once("${_}Y") })
                                ->repeat(3);
    advance_and_check_event_count 0 => 3, 1, 0;
    is_deeply \@next, [qw(XY XY XY)];
};
restart;

done_testing;
