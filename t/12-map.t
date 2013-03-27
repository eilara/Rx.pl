use strict;
use warnings;
use Test::More;
use Reactive;
use Reactive::Test::ObservableFixture;

{
my $s = subscribe Observable->from_list(1, 2, 3)
                            ->map(sub{ $_ * 2 });
advance_and_check_event_count 0 => 3, 1;
}

restart;

{
my $s = subscribe Observable->from_list(1, 2, 3)
                            ->map(sub{ ($_) x $_ });
advance_and_check_event_count 0 => 6, 1;
is_deeply \@next, [1, 2, 2, 3, 3, 3], 'flattened';
}

done_testing;

