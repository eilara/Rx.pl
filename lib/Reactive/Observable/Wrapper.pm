package Reactive::Observable::Wrapper;

use Moose;
use aliased 'Reactive::Disposable::Wrapper' => 'DisposableWrapper';

has wrap => (is => 'rw', required => 1);

extends 'Reactive::Observable';

sub observer_wrapper_package { die 'Abstract' }

sub run {
    my ($self, $observer)  = @_;
    my $observer_pkg       = ref($self). '::Observer';
    my $disposable_wrapper = DisposableWrapper->new;
    my $disposable         = $self->wrap->subscribe_observer(
       $observer_pkg->new(wrap => $observer)
    );
    $disposable_wrapper->wrap($disposable);
    return $disposable_wrapper;
}

1;

