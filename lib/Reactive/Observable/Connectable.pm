package Reactive::Observable::Connectable;

use Moose;
use aliased 'Reactive::Observable::Subject' => 'Subject';

has wrap         => (is => 'ro', required   => 1);
has subject      => (is => 'ro', lazy_build => 1, handles => [qw(run)]);
has is_connected => (is => 'rw', default    => 0);
has subscription => (is => 'rw');

extends 'Reactive::Observable';

sub _build_subject { Subject->new }

sub connect {
    my $self = shift;
    die "Can only connect once to Connectable" if $self->is_connected;
    my $disposable = $self->wrap->subscribe_observer($self->subject);
    $self->subscription($disposable);
    $self->is_connected(1);
    return $self;
}

sub disconnect {
    my $self = shift;
    $self->subscription(undef);
    $self->is_connected(0);
}

1;

