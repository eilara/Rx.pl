package Reactive::Disposable::Closure;

use Moose;

has cleanup => (is => 'rw', default => sub { sub{} });

sub DEMOLISH {
    my $self = shift;
    $self->{cleanup}->();
};

1;

__END__
