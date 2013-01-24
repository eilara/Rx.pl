package Reactive::Disposable::Handle;

use Moose;

has handle => (is => 'rw');

extends 'Reactive::Disposable';

before dispose => sub { shift->{handle} = undef };

1;

__END__
