use strict;
use warnings;
use Test::More;
use Reactive;
use Reactive::Test::ObservableFixture;

subtest 'simple map' => sub {
    my $s = subscribe Observable->from_list(1, 2, 3)
                                ->map(sub{ $_ * 2 });
    advance_and_check_event_count 0 => 3, 1;
};
restart;

subtest 'sugar for map to constant dispenses with "sub"' => sub {
    my $s = subscribe Observable->once(1)->map(2);
    is $next[0], 2;
};
restart;

subtest 'map to list is flattened' => sub {
    my $s = subscribe Observable->from_list(1, 2, 3)
                                ->map(sub{ ($_) x $_ });
    advance_and_check_event_count 0 => 6, 1;
    is_deeply \@next, [1, 2, 2, 3, 3, 3], 'flattened';
};
restart;

subtest 'map error unsubscribes' => sub {
    my $i;
    my $s = subscribe Observable->interval(100, $scheduler)
                                ->map(sub{
                                    $i++;
                                    die 'zzz' if $i == 2;
                                    $i;
                                  });
    advance_and_check_event_counts
        [   1 => 0      ],
        [ 100 => 1, 0, 0],
        [ 100 => 1, 0, 1],
        [ 100 => 1, 0, 1];
};
restart;

done_testing;

