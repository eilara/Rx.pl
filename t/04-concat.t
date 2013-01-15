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

advance_and_check_event_counts
    [1001 => 0   ],
    [1000 => 1   ],
    [1000 => 1   ],
    [2000 => 1   ],
    [2000 => 2, 1];

done_testing;

