use strict;
use warnings;

use lib './t/lib';

use Test::More;
use Reactive;
use Reactive::Test::ObservableFixture;

my $s = subscribe Observable->from_list(1, 2, 3, 4)
                            ->take_last(2);

advance_and_check_event_count 0 => 2, 1;
is_deeply \@next, [3, 4];

done_testing;

