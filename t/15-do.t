use strict;
use warnings;

use lib './t/lib';

use Test::More;
use Reactive;
use Reactive::Test::ObservableFixture;

my $i;
my $s = subscribe Observable->from_list(1, 2, 3)
                            ->do(sub{ $i++ });

advance_and_check_event_count 0 => 3, 1;
is_deeply \@next, [1, 2, 3], 'no change in do_next values';
is $i, 3, 'side-effect happened';

done_testing;

