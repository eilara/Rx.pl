package Reactive;
# ABSTRACT: Reactive programming for Perl

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

1;

__END__

=head1 SYNOPSIS

This synopsis is taken from F<eg/map.pl>:

    use Reactive;
    use Coro::Handle;

    my $o = Observable->interval(100)
                      ->map(sub{ 2 * $_ })
                      ->grep(sub{ $_ % 3 == 0 })
                      ->take(10)
                      ->push( Observable->once("Bye!") );

    my $s = $o->subscribe(
        on_next     => sub { say "on_next=$_" },
        on_complete => sub { say "complete" },
    );

    say "Running event loop, hit enter to unsubscribe...";
    Coro::Handle->new_from_fh(*STDIN)->readline;

    $s = undef;

    say "Hit enter to exit.";
    Coro::Handle->new_from_fh(*STDIN)->readline;

=head1 DESCRIPTION

Reactive programming takes after Microsoft's Reactive Extensions, which allows
you to write asynchronous code without having to mess with callbacks. It's
declarative, feature-full and elegant.

You should look at the guide (once it's written) and the available examples
for a better understanding of how to use it.

=head1 METHODS

=head2 loop

Start the event loop for your code.

=head2 unloop

Stop the event loop for your code.

=head1 EXPORTS

This module exports the C<Observable> namespace, which is short for the
L<Reactive::Observable>, which you could use manually as well.

