package Reactive::Observable::Wrapper;

use Moose;
use aliased 'Reactive::Disposable::Wrapper';

extends 'Reactive::Observable';

has source => (is => 'ro', required => 1);

sub build_wrapper_observer {
    my ($self, %args) = @_;
    die 'Abstract';
}

sub run {
    my ($self, $observer) = @_;
    my $subscription = Wrapper->new;
    my $wrapper_observer = $self->build_wrapper_observer(
        parent    => $subscription,
        target    => $observer,
    );
    my $source_subscription = $self->source
                                   ->subscribe_observer($wrapper_observer);
    $subscription->wrap($source_subscription);
    return $subscription;
}

1;

