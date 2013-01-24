package Rx::Disposable;

use strict;
use warnings;
use Moose;

has cleanup => (is => 'ro', default => sub { sub{} });

sub empty {
    my $class = shift;
    return $class->new;
}

sub DEMOLISH {
    my $self = shift;
    print "DEM=$self\n";
    $self->cleanup->();
}

1;

__END__
