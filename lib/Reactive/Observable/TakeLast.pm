package Reactive::Observable::TakeLast;

use Moose;

has count => (is => 'ro', required => 1);

extends 'Reactive::Observable::Wrapper';

augment observer_args => sub {
    my ($self) = @_;
    return (count => $self->count, inner(@_));
};

package Reactive::Observable::TakeLast::Observer;

use Moose;

has count => (is => 'ro', required => 1);
has queue => (is => 'ro', default  => sub { [] });

extends 'Reactive::Observer::Wrapper';

sub on_next {
    my ($self, $value) = @_;
    my $q = $self->queue;
    push @$q, $value;
    shift @$q if @$q > $self->count;
}

sub on_complete {
    my $self = shift;
    $self->wrap->on_next($_) for @{$self->queue};
    $self->wrap->on_complete;
    $self->unwrap;
}

before unwrap => sub { delete shift->{queue} };

1;

