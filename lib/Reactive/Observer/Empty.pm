package Reactive::Observer::Empty;

use Moose;

sub on_next     {}
sub on_complete {}
sub on_error    {}

#sub on_next     { print  "N=$_\n" }
#sub on_complete { print  "C"      }
#sub on_error    { print  "E=$_\n" }

1;

=encoding utf8

=head1 NAME

Reactive::Observer::Empty - an empty observer.

=head1 SYNOPSIS

This is an empty observer that does nothing.

=head1 METHODS

=head2 on_next

Does nothing.

=head2 on_complete

Does nothing.

=head2 on_error

Does nothing.

=cut

