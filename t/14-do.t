use strict;
use warnings;
use Test::More;
use Reactive;
use Reactive::Test::ObservableFixture;

my $i;
my $s = subscribe Observable->from_list(1, 2, 3)
                            ->do(sub{ $i++ });

advance_and_check_event_count 0 => 3, 1;
is_deeply \@next, [1, 2, 3], 'no change in do_next values';
is 3, $i, 'side-effect happened';

done_testing;

