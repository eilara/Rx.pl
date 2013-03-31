package Reactive::Observable::Do;

use Moose;

extends 'Reactive::Observable::Wrapper';

has action => (is => 'ro', required => 1);

augment observer_args => sub {
    my ($self) = @_;
    return (action => $self->action, inner(@_));
};

package Reactive::Observable::Do::Observer;

use Moose;

has action => (is => 'ro', required => 1);

extends 'Reactive::Observer::Wrapper';

sub on_next {
    my ($self, $value) = @_;
    local $_ = $value;
    eval { $self->action->($_) };
    my $err = $@;
    return $self->on_error($err) if $err;
    my $wrap = $self->wrap;
    $wrap->on_next($value);
}

before unwrap => sub { delete shift->{action} };

1;

