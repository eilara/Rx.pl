use strict;
use warnings;
use Test::More;
use Reactive;
use Reactive::Test::ObservableFixture;

my $iut = Observable->from_list(1,2,4,8)
                    ->start_with( Observable->once(0) );

my $s = subscribe $iut;

advance_and_check_event_counts [1001 => 5, 1];

is $next[0], 0, '1st value';
is $next[4], 8, 'last value';

done_testing;

