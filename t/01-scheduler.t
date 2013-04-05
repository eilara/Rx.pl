use strict;
use warnings;
use Test::More;
use aliased 'Reactive::Test::Scheduler::Virtual' => 'IUT';

my $iut = IUT->new(now => 100);

my $state = 0;

my $s1 = $iut->schedule_periodic(100, sub { $state = 1; undef });

is $state, 0, 'at t=0';

$iut->advance_by(60);
is $state, 0, 'at t=160';

$iut->advance_by(50);
is $state, 1, 'at t=210';

$iut->advance_by(1000);
is $state, 1, 'at t=1210';

my $s2 = $iut->schedule_periodic(200, sub { $state++; 300 });

$iut->advance_by(190);
is $state, 1, 'at t=1400';

$iut->advance_by(20);
is $state, 2, 'at t=1420';

$iut->advance_by(300);
is $state, 3, 'at t=1720';

$iut->advance_by(900);
is $state, 6, 'at t=2620';

$s2 = undef;

$iut->advance_by(10000);
is $state, 6, 'at t=12620';

done_testing;
