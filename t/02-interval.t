use strict;
use warnings;
use Test::More;
use Reactive;
use Reactive::Test::ObservableFixture;

my $iut = Observable->interval(400, $scheduler);

my $s = subscribe $iut;

# no firing on subscribe
advance_and_check_event_count    0 => 0;

# no firing before time
advance_and_check_event_count  300 => 0;

# 1st notification
advance_and_check_event_count  200 => 1;
is $next[0], 0, '1st value';

# 2nd notification
advance_and_check_event_count  400 => 2;
is $next[1], 1, '2nd value';

# 4 more notifications happen in 1600 msec
advance_and_check_event_count 1600 => 6;

$s = undef;

# no notifications after unsubscribe
advance_and_check_event_count 2000 => 6;

done_testing;
