use strict;
use warnings;
use Test::More;
use aliased 'DateTime::Duration';
use Rx;
use Rx::Test::ObservableFixture;

my $iut = Rx->interval(Duration->new(seconds => 1), $scheduler)
            ->count;

my $s   = subscribe $iut;

advance_and_check_event_count 1001 => 1;
advance_and_check_event_count 1000 => 2;
is $next[-1], 2, '2nd event';

advance_and_check_event_count 5001 => 7;
is $next[-1], 7, '7th event';

done_testing;

