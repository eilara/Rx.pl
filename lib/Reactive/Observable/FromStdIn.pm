package Reactive::Observable::FromStdIn;

use Moose;
use AnyEvent;

extends 'Reactive::Observable::FromGlobalListener';

sub build_global_listener {
    my ($self, $on_next, $on_complete, $on_error) = @_;
    return AE::io *STDIN, 0, sub {
        my $line = <STDIN>;
        if (defined $line) {
            chomp $line;
            $on_next->($line);
        } else { # EOF received
            $on_complete->();
        }
    };
}


1;

