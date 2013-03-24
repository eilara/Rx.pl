package Reactive::Test::Scheduler::Virtual;

use Moose;
use Reactive::Disposable::Closure;

has now => (is => 'rw', default => 0); # msec

has actions => (is => 'rw', default => sub { [] });

with 'Reactive::Scheduler';

sub schedule_once {
    my ($self, $at, $action) = @_;
    $self->add_action($at + $self->now, $action);
    return Reactive::Disposable::Closure->new
        (cleanup => sub { $self->remove_action($action) });
}

sub add_action {
    my ($self, $at, $action) = @_;
    push @{$self->actions}, [$at, $action];
}

sub remove_action {
    my ($self, $action) = @_;
    $self->actions([grep { $_->[1] ne $action } @{$self->actions}]);
}

sub sort_actions {
    my $self = shift;
    return sort { $a->[0] <=> $b->[0] } @{$self->actions};
}

sub advance_by {
    my ($self, $ms) = @_;
    my $max = $self->{now} + $ms;
    while (my @sorted = $self->sort_actions) {
        my ($t, $action) = @{$sorted[0]};
        last if $t > $max;
        $self->{now} = $t;
        $self->remove_action($action);
        $action->();
    }
    $self->{now} = $max;
}

sub restart {
    my $self = shift;
    $self->actions([]);
    $self->now(0);
}

1;
