use strict;
use warnings;
use Test::More;
use Reactive;
use Reactive::Test::ObservableFixture;

{
my $iut = Observable->from_list(1,2,4,8)
                    ->start_with( Observable->once(0) );

my $s = subscribe $iut;

advance_and_check_event_counts [1001 => 5, 1];

is $next[0], 0, '1st value';
is $next[4], 8, 'last value';
}

restart;

{
my $s = subscribe Observable->once(100)->start_with(1, 2, 3);
advance_and_check_event_count 0 => 4, 1;
}

restart;

{
my $s = subscribe
                  Observable->timer(5000, $scheduler)
    ->start_with( Observable->timer(2000, $scheduler) );
advance_and_check_event_counts
    [1001 => 0   ],
    [1000 => 1   ],
    [1000 => 1   ],
    [2000 => 1   ];
undef $s;
advance_and_check_event_count 10000 => 1;
}

restart;

{
my $s = subscribe               Observable->once(333)
                  ->start_with( Observable->timer(2000, $scheduler) );
advance_and_check_event_counts
    [1001 => 0   ],
    [1000 => 2,1 ],
}
done_testing;

