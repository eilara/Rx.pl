package Reactive::Disposable::Composite;

use Moose;
use Set::Object;

has children => (is => 'ro', default => sub { Set::Object->new }, handles => {
    wrap              => 'insert',
    unwrap_disposable => 'remove',
    clear             => 'clear',
});

sub unwrap {
    my ($self, $disposable) = @_;
    return $self->unwrap_disposable($disposable)
        if $disposable;
    $self->clear;
}

# avoid Set::Object warning on destruction
sub DEMOLISH { shift->clear }

1;

