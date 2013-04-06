use strict;
use warnings;
use Test::More;
use Reactive;
use Reactive::Test::ObservableFixture;

# merge a sequence with itself in fluent style.
# without "let", this would require a temp var:
#    $o = Observable->from_list(1, 2, 3);
#    $merge = $o->merge( $o->sub({ $_ }) );
my $s = subscribe
    Observable->from_list(1, 2, 3)
              ->let(sub{ $_[0]->merge( $_[0]->map(sub{ $_ }) ) });

advance_and_check_event_count 0 => 6, 1;
is_deeply \@next, [1, 2, 3, 1, 2, 3];

done_testing;

