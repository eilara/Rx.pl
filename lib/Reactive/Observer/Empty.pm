package Reactive::Observer::Empty;

use Moose;

sub on_next     {}
sub on_complete {}
sub on_error    {}

#sub on_next     { print  "N=$_\n" }
#sub on_complete { print  "C"      }
#sub on_error    { print  "E=$_\n" }

1;

