use strict;
use warnings;
use Test::More;
use Reactive;
use Reactive::Test::ObservableFixture;

my $o1  = Observable->timer(2000, $scheduler);
my $o2  = Observable->timer(3000, $scheduler);
my $iut = $o1->merge($o2);
my $s   = subscribe $iut;

advance_and_check_event_counts
    [1001 => 0   ],
    [1000 => 1   ],
    [1000 => 2, 1];

done_testing;

