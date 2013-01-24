package Rx;

use strict;
use warnings;
use Coro;
use Coro::EV;
use Coro::Handle;
use aliased 'Rx::Observable';

sub once {
    my ($class, $value) = @_;
    Observable->create(sub {
        my ($observer, $scheduler) = @_;
        $observer->on_next($value);
        $observer->on_complete;
    });
}

sub empty {
    my ($class, $value) = @_;
    Observable->create(sub {
        my ($observer, $scheduler) = @_;
        $observer->on_complete;
    });
}

sub never {
    my ($class) = @_;
    Observable->create(sub {});
}

sub throw {
    my ($class, $err) = @_;
    Observable->create(sub {
        my ($observer, $scheduler) = @_;
        $observer->on_error($err);
    });
}

sub range {
    my ($class, $from, $size) = @_;
    Observable->create(sub {
        my ($observer, $scheduler) = @_;
        my $i = $from;
        my $to = $from + $size;
        while ($i < $to) { $observer->on_next($i++) }
        $observer->on_complete;
    });
}

sub interval {
    my ($class, $duration, $scheduler) = @_;
    Observable->generate(
        0,
        sub { 1 },
        sub { 1 + $_ },
        sub { $_ },
        sub { $duration },
        $scheduler,
    );
}

sub timer {
    my ($class, $duration, $scheduler) = @_;
    Observable->generate(
        0,
        sub { 0 },
        sub { $_ },
        sub { 1 },
        sub { $duration },
        $scheduler,
    );
}

sub from_stdin {
    my $self = shift;
    Observable->create(sub {
        my ($observer, $scheduler) = @_;
        my $fh = Coro::Handle->new_from_fh(*STDIN);
        while (1) {
            my $line = $fh->readline;
            chomp $line;
            $observer->on_next($line);
        }
    });
}

sub run { EV::loop }

1;

