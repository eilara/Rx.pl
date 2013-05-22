use strict;
use warnings;

use lib './t/lib';

use Test::More;
use Reactive;
use Reactive::Test::ObservableFixture;

my $s = subscribe Observable->from_list(4, 3, 2, 1, 0)
                            ->skip(3);

advance_and_check_event_count 0 => 2, 1, 0;
is_deeply \@next, [1, 0], '3 skipped';

done_testing;

