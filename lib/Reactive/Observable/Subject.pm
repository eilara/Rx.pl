package Reactive::Observable::Subject;

use Moose;
use Set::Object qw(weak_set);
use aliased 'Reactive::Disposable::Empty'   => 'EmptyDisposable';
use aliased 'Reactive::Disposable::Wrapper' => 'DisposableWrapper';

extends 'Reactive::Observable';

# when we complete/error we delete this to block any more
# notifications from taking place
has observers => (is => 'ro', default => sub { weak_set });

sub run {
    my ($self, $observer) = @_;
    return EmptyDisposable->new unless $self->{observers};
    my $disposable_wrapper = DisposableWrapper->new(wrap => $observer);
    $self->observers->insert($observer) if $self->{observers};
    return $disposable_wrapper;
}

sub on_next {
    my ($self, $value) = @_;
    return unless $self->{observers};
    $_->on_next($value) for $self->observers->members;
}

sub on_complete {
    my $self = shift;
    return unless $self->{observers};
    $_->on_complete for $self->observers->members;
    $self->unwrap;
}

sub on_error {
    my ($self, $error) = @_;
    return unless $self->{observers};
    $_->on_error($error) for $self->observers->members;
    $self->unwrap;
}

sub unwrap {
   my $self = shift;
   # work around Set::Object issue- if you don't clear the set
   # you will get an attempt to free unreferenced scalar on
   # global destruction
   $self->{observers}->clear;
   delete $self->{observers};
}

1;

