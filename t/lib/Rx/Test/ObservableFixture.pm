package Rx::Test::ObservableFixture;

use strict;
use warnings;
use Test::More;
use Test::Builder;
use Coro;
use Rx;
use aliased 'Rx::Test::Scheduler::Virtual' => 'Scheduler';

use base 'Exporter';
our @EXPORT=qw(
    @next @complete @error
    $scheduler
    advance_and_check_event_count subscribe run_loop
);

our (@next, @complete, @error);

our $scheduler = Scheduler->new;

sub advance_and_check_event_count($$;$$) {
    my ($advance_by, $next, $complete, $error) = @_;
    $complete ||= 0;
    $error    ||= 0;
    $scheduler->advance_by($advance_by) if $advance_by;
    my $now = $scheduler->now;
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    my ($actual_next, $actual_complete, $actual_error) =
        (scalar @next, scalar @complete, scalar @error);
    is_deeply
        {
            next     => $actual_next,
            complete => $actual_complete,
            error    => $actual_error,
        },
        {
            next     => $next,
            complete => $complete,
            error    => $error,
        },
        "t=$now (next=$next, complete=$complete, error=$error)";
}

sub subscribe($) {
    my $o = shift;
    my $s = $o->subscribe(
        on_next     => sub { push @next    , $_ },
        on_complete => sub { push @complete, 1  },
        on_error    => sub { push @error   , $_ },
    );
    Rx->run;
    return $s;
}

1;
