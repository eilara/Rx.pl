package Reactive::Disposable::Wrapper;

use Moose;

has wrap => (is => 'rw');

sub unwrap { shift->wrap(undef) }

1;

