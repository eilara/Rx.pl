package Reactive::Observable::FromStdIn;

use Moose;
use AnyEvent;
use Reactive::Disposable::Handle;

extends 'Reactive::Observable';

sub run {
    my ($self, $observer) = @_;
    my $handle = AE::io *STDIN, 0, sub {
        my $line = <STDIN>;
        # TODO complete on ctrl-d
        chomp $line;
        $observer->on_next($line);
    };
    return Reactive::Disposable::Handle->new(handle => $handle);
}


1;

