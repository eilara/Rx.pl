package Reactive::Observable::ReplaySubject;

use Moose;
use aliased 'Reactive::Observable::Subject';

has queue   => (is => 'ro', default => sub{ [] });
has subject => (is => 'ro', lazy_build => 1,
                handles => [qw(on_error on_complete)]);

extends 'Reactive::Observable';

sub _build_subject { Subject->new }

sub run {
    my ($self, $observer) = @_;
    my $disposable = $self->subject->run($observer);
    $_->accept($observer) for @{$self->queue};
    return $disposable;
}

sub on_next {
    my ($self, $value) = @_;
    push @{$self->queue}, $value;
    $value->accept($self->subject);
}

1;

