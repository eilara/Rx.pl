use strict;
use warnings;
use Test::More;
use Reactive;
use Reactive::Test::ObservableFixture;

my $iut = Observable->from_list(4, 3, 2, 1, 0)
                    ->skip(3);

my $s = subscribe $iut;

advance_and_check_event_count 0 => 2, 1, 0;
is_deeply \@next, [1, 0], '3 skipped';

done_testing;

