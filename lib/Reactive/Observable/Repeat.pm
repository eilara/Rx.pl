package Reactive::Observable::Repeat;

use Moose;

extends 'Reactive::Observable::Wrapper';

# count = undef means repeat forever
has _count => (is => 'ro');

augment observer_args => sub {
    my ($self) = @_;
    return (
        remaining  => $self->_count,
        observable => $self->wrap,
        inner(@_));
};

package Reactive::Observable::Repeat::Observer;

use Moose;

has observable => (is => 'ro', required => 1);
has remaining  => (is => 'rw', required => 1);

extends 'Reactive::Observer::Wrapper';

sub on_complete {
    my $self = shift;
    my $remaining = $self->remaining;
    if (defined $remaining) {
        $self->remaining(--$remaining);
        if ($remaining <= 0) {
            $self->wrap->on_complete;
            $self->unwrap;
            return;
        }
    }

    my $disposable = $self->observable->subscribe_observer($self);
    $self->wrap_with_parent($disposable) unless $self->is_disposing;
}

before unwrap => sub { delete shift->{observable} };

1;

