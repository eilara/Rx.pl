use strict;
use warnings;

use lib './t/lib';

use Test::More;
use Reactive;
use Reactive::Test::ObservableFixture;

subtest 'no errors' => sub {
    my $s = subscribe Observable->from_list(1, 2, 3)->materialize;
    advance_and_check_event_count 0 => 4, 1, 0;
    is $next[2]->wrap, 3, 'on_next';
    is ref $next[3],
       'Reactive::Observable::Materialize::Notification::Complete',
       'on_complete';
};
restart;

subtest 'no errors' => sub {
    my $s = subscribe Observable->once(9)
                                ->push(Observable->throw('X'))
                                ->materialize;
    advance_and_check_event_count 0 => 2, 1, 0;
    is $next[0]->wrap,  9 , 'on_next';
    is $next[1]->wrap, 'X', 'on_error';
};
restart;

done_testing;
