package Reactive::Scheduler;

use Moose::Role;
use Scalar::Util qw(weaken);
use Reactive::Disposable::Wrapper;

requires qw(schedule_once now);

# at is in msec
sub schedule_periodic {
    my ($self, $at, $action) = @_;
    my $disposable = Reactive::Disposable::Wrapper->new;
    $self->_schedule_periodic($at, $action, $disposable);
    return $disposable;
}

sub _schedule_periodic {
    my ($self, $at, $action, $disposable) = @_;
    return unless $disposable; # we have been disposed, fire no more

    weaken $disposable;
    # schedule callback has strong refs to: scheduler, action
    # and a weak ref to: disposable
    my $callback = sub {
        my $new_at = $action->();
        return unless $disposable; # we have been disposed, fire no more
        if (defined $new_at) {
            $self->_schedule_periodic($new_at, $action, $disposable);
        } else {
            $disposable->unwrap;
        }
    };
    my $wrap = $self->schedule_once($at, $callback);
    $disposable->wrap($wrap);
}


1;
