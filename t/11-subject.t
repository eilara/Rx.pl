use strict;
use warnings;
use Test::More;
use Reactive;
use Reactive::Test::ObservableFixture;

my $iut = Observable->subject;
my $s1  = subscribe $iut;

advance_and_check_event_count 0 => 0;

$iut->on_next(12);
advance_and_check_event_count 0 => 1;
is_deeply $next[0], 12, '1st event';

$iut->on_next(13);
advance_and_check_event_count 0 => 2;
is_deeply $next[1], 13, '2nd event';

$iut->on_next(14);
advance_and_check_event_count 0 => 3;
is_deeply $next[2], 14, '3rd event';

my $s2  = subscribe $iut;

$iut->on_complete;

# both subscribers get their complete events
advance_and_check_event_count 0 => 3, 2;

done_testing;

