package Reactive::Disposable::Composite;

use Moose;
use Set::Object;

has wrap => (is => 'ro', default => sub { Set::Object->new });

sub unwrap {
}

1;

