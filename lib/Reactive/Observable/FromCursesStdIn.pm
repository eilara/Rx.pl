package Reactive::Observable::FromCursesStdIn;

use Moose;
use AnyEvent;
use AnyEvent::Handle;

extends 'Reactive::Observable::FromGlobalListener';

sub build_global_listener {
    my ($self, $on_next, $on_complete, $on_error) = @_;
    my $handle; $handle = new AnyEvent::Handle
        fh      => \*STDIN,
        on_read => sub {
            my $char = $handle->{rbuf};
            $handle->{rbuf} = '';
            # sometimes we get more than one char
            $on_next->(substr $char, -1, 1);
        },
        on_error => sub {
           my ($handle, $fatal, $message) = @_;
           $on_error->($message);
        };
    return $handle;    
}

sub destroy_handle { pop->destroy }

1;

