package Reactive::Disposable;

use strict;
use warnings;
use Moose;

sub empty { return shift->new }

sub dispose {
    my $self = shift;
}

sub DEMOLISH {
    my $self = shift;
    $self->dispose;
}

1;

__END__
