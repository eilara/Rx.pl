package Rx::Test::ObservableFixture;

use strict;
use warnings;
use Test::More;
use Test::Builder;
use Coro;
use aliased 'Rx::Test::Scheduler::Virtual' => 'Scheduler';

use base 'Exporter';
our @EXPORT=qw(
    @next @complete @error
    $scheduler
    advance_and_check_event_count subscribe
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
    is scalar @next    , $next    , "\@next     at t=$now";
    is scalar @complete, $complete, "\@complete at t=$now";
    is scalar @error   , $error   , "\@error    at t=$now";
}

sub subscribe($) {
    my $o = shift;
    my $s = $o->subscribe(
        on_next     => sub { push @next    , $_ },
        on_complete => sub { push @complete, 1  },
        on_error    => sub { push @error   , $_ },
    );
    cede;
    return $s;
}

1;
