package Reactive::Observable::Delay;

use Moose;

extends 'Reactive::Observable::Wrapper';

has delay => (is => 'ro', required => 1); # msec

augment observer_args => sub {
    my ($self, $observer, $disposable_wrapper) = @_;
    return (
        delay              => $self->delay,
        disposable_wrapper => $disposable_wrapper,
        inner(@_),
    );
};

package Reactive::Observable::Delay::Observer;

use Moose;

has delay              => (is => 'ro', required => 1); # msec
has disposable_wrapper => (is => 'ro', required => 1, weak_ref => 1);

extends 'Reactive::Observer::Wrapper';

sub on_next {
#    my ($self, $value) = @_;
#    my $wrap = $self->wrap;
#    my $disposable = $self->schedule_once($self->delay, sub {
#        $wrap->on_next($value);
#    });
#    my $disposable_wrapper = $self->disposable_wrapper;
#    my $disposable_wrapped = $disposable_wrapper->wrap || [];
#    push @$disposable_wrapped, $disposable;
#    $disposable_wrapper->wrap($disposable_wrapped);
}

1;

