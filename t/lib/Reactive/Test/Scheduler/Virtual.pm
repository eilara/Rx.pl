package Reactive::Test::Scheduler::Virtual;

use Moose;
use Scalar::Util qw(weaken);
use Heap::MinMax;
use Reactive::Disposable::Closure;

with 'Reactive::Scheduler';

has now => (is => 'rw', default => 0); # msec

has actions => (is => 'rw', default => sub { [] });

# at is in msec
sub schedule_at {
    my ($self, $at, $action) = @_;
    my $subscription = Reactive::Disposable::Closure->new;
    $self->_schedule_at($at, $action, $subscription);
    return $subscription;
}

sub _schedule_at {
    my ($self, $at, $action, $disposable) = @_;
    weaken $disposable;
    return unless $disposable;
    my $wrapper_action = sub {
        my $new_at = $action->();
        if (defined $new_at) {
            $self->_schedule_at($new_at, $action, $disposable);
        } else {
            # our disposable could have already been disposed
            $disposable->dispose if $disposable;
        }
    };
    $self->add_action($at + $self->now, $wrapper_action);
    $disposable->cleanup(sub { $self->remove_action($wrapper_action) });
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

1;
