package Reactive::Observable::FromGlobalListener;

use Moose;
use Reactive::Observable;
use aliased 'Reactive::Disposable::Wrapper' => 'DisposableWrapper';
use aliased 'Reactive::Disposable::Closure' => 'DisposableClosure';

extends 'Reactive::Observable';

my ($Subject, $Handle, $Subscription_Count);

sub run {
    my ($self, $observer) = @_;

    if (++$Subscription_Count == 1) { # 1st subscription
        $Subject = Reactive::Observable->subject;
        $Handle  = $self->build_global_listener(
            sub{ $Subject->on_next(shift)          },
            sub{ $Subject->on_complete    ; $self->init },
            sub{ $Subject->on_error(shift); $self->init },
        );
    }
    
    my $cleanup = sub {
        $Subscription_Count-- if $Subscription_Count > 0;
        $self->init unless $Subscription_Count;
    };

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

sub init {
    my $self = shift;
    $self->destroy_handle($Handle);
    $Subscription_Count = 0;
    undef $Handle;
    undef $Subject;
}

sub build_global_listener { die 'Abstract' }

sub destroy_handle {}

1;

