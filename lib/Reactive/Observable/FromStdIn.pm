package Reactive::Observable::FromStdIn;

use Moose;
use AnyEvent;
use Reactive::Observable;
use aliased 'Reactive::Disposable::Wrapper' => 'DisposableWrapper';
use aliased 'Reactive::Disposable::Closure' => 'DisposableClosure';

extends 'Reactive::Observable';

my ($Subject, $Handle, $Subscription_Count);

sub run {
    my ($self, $observer) = @_;
    $Subscription_Count++;
    init_stdin() if $Subscription_Count == 1; # 1st subscription
    
    my $cleanup = sub
        { $Subscription_Count-- if $Subscription_Count > 0 };

    # disposable_closure   = subscription to ref counted cleanup
    # disposable_inner     = subscription on subject
    # disposables          = we want both subscriptions
    # disposable_wrapper   = the subscription returned

    my $disposable_closure = DisposableClosure->new(cleanup => $cleanup);
    my $disposable_inner   = $Subject->subscribe_observer($observer);
    my $disposables        = [$disposable_inner, $disposable_closure];
    my $disposable_wrapper = DisposableWrapper->new(wrap => $disposables);

    return $disposable_wrapper;
}

sub init_stdin {
    $Subject = Reactive::Observable->subject;
    $Handle  = AE::io *STDIN, 0, sub {
        my $line = <STDIN>;
        if (defined $line) {
            chomp $line;
            $Subject->on_next($line);
        } else { # EOF received
            $Subscription_Count = 0;
            undef $Handle;
            $Subject->on_complete;
        }
    };
}


1;

