use strict;
use warnings;
use Test::More;
use Reactive;
use Reactive::Test::ObservableFixture;

my $i;
my $iut = Observable->from_list(1, 2, 3)
                    ->do(sub{ $i++ })
                    ->memoize;
my $s1 = subscribe $iut;
advance_and_check_event_count 0 => 3, 1, 0;

my $s2 = subscribe $iut;
advance_and_check_event_count 0 => 6, 2, 0;

is $i, 3, 'side effects not duplicated';
is_deeply \@next, [1, 2, 3, 1, 2, 3];

done_testing;
