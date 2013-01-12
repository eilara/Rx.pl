package Rx::Observable;

use strict;
use warnings;

sub map {
    my ($self, $map) = @_;
    $self->create_on_parent(sub {
        my $observer = shift;
        (on_next => sub { $observer->on_next($map->($_)) });
    });
}

sub grep {
    my ($self, $predicate) = @_;
    $self->create_on_parent(sub {
        my $observer = shift;
        (on_next => sub {
                $predicate->($_)
             && $observer->on_next($_);
        });
    });
}

sub concat {
    my ($self, $observable) = @_;
    $self->create_on_parent(sub {
        my ($observer, $scheduler, $set_subscription) = @_;
        (on_complete => sub {
            $set_subscription->
                ($observable->subscribe_observer($observer))
        });
    });
}

sub count {
    my ($self, $observable) = @_;
    $self->create_with_parent(sub {
        my ($observer, $scheduler) = @_;
        my $counter = 1;
        return $self->subscribe_observer(
            $observer, on_next => sub
                { $observer->on_next($counter++) },
        );
    });
}

1;

__END__
