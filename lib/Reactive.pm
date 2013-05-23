package Reactive;

use strict;
use warnings;
use Coro;
use Coro::EV;
use Coro::Handle;
use aliased 'Reactive::Observable';

our $VERSION = '0.0.1';

use base 'Exporter';
our @EXPORT=qw(Observable);

=head1 METHODS

=head2 $class->loop()

Start the main loop.

=head2 $class->unloop()

Stop the main loop.

=cut

sub loop   { EV::loop }
sub unloop { EV::unloop }

# ABSTRACT: Reactive programming for Perl.

1;

