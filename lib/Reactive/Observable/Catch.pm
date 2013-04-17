package Reactive::Observable::Catch;

use Moose;

# from error to new observable
has projection => (is => 'ro', required => 1);

extends 'Reactive::Observable::Wrapper';

augment observer_args => sub {
    my ($self) = @_;
    return (projection => $self->projection, inner(@_));
};

package Reactive::Observable::Catch::Observer;

use Moose;

has projection => (is => 'ro', required => 1);

extends 'Reactive::Observer::Wrapper';

sub on_error {
    my ($self, $error) = @_;
    local $_ = $error;
    my $next_observable;
    eval { $next_observable = $self->projection->($_) };
    my $err = $@;
    if ($err) {
        $self->wrap->on_error($err);
        $self->unwrap;
        return;
    }
    my $disposable = $next_observable->subscribe_observer($self->wrap);
    $self->wrap_with_parent($disposable) unless $self->is_disposing;
}

before unwrap => sub { delete shift->{projection} };

1;

