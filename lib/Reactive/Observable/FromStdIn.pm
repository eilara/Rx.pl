package Reactive::Observable::FromStdIn;

use Moose;
use Scalar::Util qw(weaken);
use AnyEvent;
use aliased 'Reactive::Disposable::Wrapper' => 'DisposableWrapper';

extends 'Reactive::Observable';

sub run {
    my ($self, $observer) = @_;
    my $disposable_wrapper = DisposableWrapper->new;
    my $handle = $self->create_handle($observer, $disposable_wrapper);
    $disposable_wrapper->wrap($handle);
    return $disposable_wrapper;
}

sub create_handle {
    my ($self, $observer, $disposable_wrapper) = @_;
    weaken $disposable_wrapper;
    return AE::io *STDIN, 0, sub {
        my $line = <STDIN>;
        if (defined $line) {
            chomp $line;
            $observer->on_next($line);
        } else {
            $observer->on_complete;
            $disposable_wrapper->unwrap;
        }
    };
}


1;

