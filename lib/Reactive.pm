package Reactive;

use strict;
use warnings;
use Coro;
use Coro::EV;
use Coro::Handle;
use aliased 'Reactive::Observable';

use base 'Exporter';
our @EXPORT=qw(Observable);

sub run { EV::loop }

1;

