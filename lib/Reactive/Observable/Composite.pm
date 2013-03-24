package Reactive::Observable::Composite;

use Moose;
use aliased 'Reactive::Disposable::Wrapper' => 'DisposableWrapper';

extends 'Reactive::Observable';

sub run {
    my ($self, $observer)  = @_;
    my $disposable_wrapper = DisposableWrapper->new;
    my $observer_pkg       = ref($self). '::Observer';
    my $disposable         = $self->wrap->subscribe_observer(
       $observer_pkg->new(
           $self->observer_args($observer, $disposable_wrapper)
       )
    );
    $disposable_wrapper->wrap($disposable);
    return $disposable_wrapper;
}

sub observer_args {
    my ($self, $observer, $disposable_wrapper) = @_;
    return (inner(@_));
}

1;

