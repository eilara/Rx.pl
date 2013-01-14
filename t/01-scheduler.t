use strict;
use warnings;
use Test::More;
use Coro;
use aliased 'Rx::Scheduler::Virtual' => 'IUT';

my $iut = IUT->new(now => 100);

my $state = 0;

my $coro = async {
    $state = 1;
    $iut->rest_msec(50);
    $state = 2;
};

is $state, 0, 'at t=0';

cede;

is $state, 1, 'at t=100';

$iut->advance_by(60);

cede;

is $state, 2, 'at t=160';

done_testing;
