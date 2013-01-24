package Reactive::Disposable;

use Moose;

has is_disposed => (is => 'rw', default => 0);

sub empty { return shift->new }

sub dispose {
    my $self = shift;
    $self->{is_disposed} = 1;
}

sub DEMOLISH {
    my $self = shift;
    $self->dispose unless $self->{is_disposed};
}

1;

__END__
