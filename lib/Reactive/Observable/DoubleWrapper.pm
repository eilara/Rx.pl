package Reactive::Observable::DoubleWrapper;

use Moose;
use aliased 'Reactive::Disposable::Wrapper';

has o1 => (is => 'ro', required => 1);
has o2 => (is => 'ro', required => 1);

extends 'Reactive::Observable';

sub build_wrapper_observer {
    my ($self, %args) = @_;
    die 'Abstract';
}

sub run {
    my ($self, $observer) = @_;
    my $subscription = Wrapper->new;
    my $wrapper_observer = $self->build_wrapper_observer(
        parent => $subscription,
        target => $observer,
    );
    my $s1 = $self->map_o1($self->o1)
                  ->subscribe_observer($wrapper_observer);
    my $s2 = $self->map_o2($self->o2)
                  ->subscribe_observer($wrapper_observer);
    $subscription->wrap([$s1, $s2]);
    return $subscription;
}

sub map_o1 { pop }
sub map_o2 { pop }

1;

