package Reactive::Observable::Composite;

use Moose;
use aliased 'Reactive::Disposable::Wrapper' => 'DisposableWrapper';

extends 'Reactive::Observable';

sub run {
    my ($self, $observer)  = @_;
    my $disposable_parent = $self->build_disposable_parent;
    my $observer_pkg      = ref($self). '::Observer';
    my $observer_wrapper  = $observer_pkg->new
        ($self->observer_args($observer, $disposable_parent));

    my @disposables = map { $_->subscribe_observer($observer_wrapper) }
        $self->initial_subscriptions;
    $self->fill_disposable_parent($disposable_parent, @disposables);

    return $disposable_parent;
}

sub build_disposable_parent { DisposableWrapper->new }

sub fill_disposable_parent {
    my ($self, $disposable_parent, @disposables) = @_;
    # we want to save the inner disposables but not in case they
    # have, on subscription, decided to set the inner disposable
    # themselves, e.g. as Push would do if o1 was Observable->once
    $disposable_parent->wrap([@disposables])
        unless $disposable_parent->wrap;
}

sub initial_subscriptions { () }

sub observer_args {
    my ($self, $observer, $disposable_parent) = @_;
    return (
       wrap              => $observer,
       disposable_parent => $disposable_parent,
       inner(@_),
   );
}

1;

