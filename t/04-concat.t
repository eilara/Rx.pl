use strict;
use warnings;
use Test::More;
use aliased 'DateTime::Duration';
use Rx;
use Rx::Test::ObservableFixture;

my $o1  = Rx->timer(Duration->new(seconds => 2), $scheduler);
my $o2  = Rx->timer(Duration->new(seconds => 5), $scheduler);
my $iut = $o1->concat($o2);
my $s   = subscribe $iut;

advance_and_check_event_count 1001 => 0;
advance_and_check_event_count 1000 => 1;
advance_and_check_event_count 1000 => 1;
advance_and_check_event_count 2000 => 1;
advance_and_check_event_count 2000 => 2, 1;

done_testing;

