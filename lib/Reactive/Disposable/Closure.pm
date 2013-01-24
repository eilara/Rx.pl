package Reactive::Disposable::Closure;

use Moose;

has cleanup => (is => 'rw', default => sub { sub{} });

extends 'Reactive::Disposable';

before dispose => sub {
    my $self = shift;
    $self->{cleanup}->();
    $self->{cleanup} = undef;
};

1;

__END__
