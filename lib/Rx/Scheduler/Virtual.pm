package Rx::Scheduler::Virtual;

use strict;
use warnings;
use Moose;
use Coro;
use Coro::EV;
use Coro::AnyEvent;
use Coro::Signal;
use Rx::Disposable;
use Heap::Simple;

extends 'Rx::Scheduler::Coro';

has now => (is => 'rw', default => 0); # msec

has queue => (is => 'ro', lazy_build => 1, handles => {
    add_signal  => 'insert',
    peek_signal => 'first',
    pop_signal  => 'extract_first',
});

sub _build_queue { Heap::Simple->new(elements => ['Array']) }

sub rest {
    my ($self, $duration) = @_;
    $self->rest($duration->seconds*1000);
}

sub rest_msec {
    my ($self, $ms) = @_;
    my $sig = Coro::Signal->new;
    $self->add_signal([$ms + $self->now, $sig]);
    $sig->wait;
}

sub advance_by {
    my ($self, $ms) = @_;
    $self->{now} += $ms;
    while (my $item = $self->peek_signal) {
        my ($t, $signal) = @$item;
        last if $t > $self->now;
        $self->pop_signal;
        $signal->send;
    }
}

1;
