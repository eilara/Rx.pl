use strict;
use warnings;
use Test::More;
use Reactive;
use Reactive::Test::ObservableFixture;

my ($n, $c, $e) = (0, 0, 0);
Observable->from_list(1, 2, 3)
          ->foreach(
              on_next     => sub { $n++ },
              on_complete => sub { $c++ },
              on_error    => sub { $e++ },
          );

is $n, 3, 'on_next';
is $c, 1, 'on_complete';
is $e, 0, 'on_error';

done_testing;

