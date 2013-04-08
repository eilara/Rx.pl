package Reactive::Observable::Map;

use Moose;

has projection => (is => 'ro', required => 1);

extends 'Reactive::Observable::Wrapper';

augment observer_args => sub {
    my ($self) = @_;
    return (projection => $self->projection, inner(@_));
};

package Reactive::Observable::Map::Observer;

use Moose;

has projection => (is => 'ro', required => 1);

extends 'Reactive::Observer::Wrapper';

sub on_next {
    my ($self, $value) = @_;
    local $_ = $value;
    my @new_values;
    eval {
        $_ = $value;
        @new_values = $self->projection->($_);
    };
    my $err = $@;
    return $self->on_error($err) if $err;
    my $wrap = $self->wrap;
    $wrap->on_next($_) for @new_values;
}

before unwrap => sub { delete shift->{projection} };

1;

