package Reactive::Observable::Composite;

use Moose;
use aliased 'Reactive::Disposable::Wrapper' => 'DisposableWrapper';

extends 'Reactive::Observable';

sub run {
    my ($self, $observer)  = @_;
    my $disposable_wrapper = DisposableWrapper->new;
    my $observer_pkg       = ref($self). '::Observer';
    my $observer_wrapper   = $observer_pkg->new
        ($self->observer_args($observer, $disposable_wrapper));

    my @disposables = map { $_->subscribe_observer($observer_wrapper) }
        $self->initial_subscriptions;

    # we want to save the inner disposables but not in case they
    # have, on subscription, decided to set the inner disposable
    # themselves, e.g. as Push would do if o1 was Observable->once
    $disposable_wrapper->wrap([@disposables])
        unless $disposable_wrapper->wrap;
    return $disposable_wrapper;
}

sub initial_subscriptions { () }

sub observer_args {
    my ($self, $observer, $disposable_wrapper) = @_;
    return (wrap => $observer, inner(@_));
}

1;

