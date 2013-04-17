package Reactive::Observable::Scan;

use Moose;

has [qw(seed projection)] => (is => 'ro', required => 1);

extends 'Reactive::Observable::Wrapper';

augment observer_args => sub {
    my ($self) = @_;
    return (
        state      => $self->seed,
        projection => $self->projection,
        inner(@_),
    );
};

package Reactive::Observable::Scan::Observer;

use Moose;

has state      => (is => 'rw', required => 1);
has projection => (is => 'ro', required => 1);

extends 'Reactive::Observer::Wrapper';

sub on_next {
    my ($self, $value) = @_;

    my $state = $self->state;
    my $new_state;
    local $_ = [$state, $value];
    eval { $new_state = $self->projection->($state, $value) };
    my $err = $@;
    return $self->on_error($err) if $err;

    $self->state($new_state);
    $self->wrap->on_next($new_state);
}

before unwrap => sub {
    my $self = shift;
    delete $self->{projection};
    delete $self->{state};
};

1;

