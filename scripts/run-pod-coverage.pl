#!/usr/bin/perl

use strict;
use warnings;
use autodie;

use IO::All;


my $ini = 'dist.ini';

my $orig_text = io($ini)->all;
io($ini)->print($orig_text =~ s/^;\s*(\Q[PodCoverageTests]\E\s*)$/$1/mrs);
system("dzil", "build");
io($ini)->print($orig_text);

my $dir = 'Reactive-0.0.1';

system("export RELEASE_TESTING=1; cd $dir && perl Build.PL && ./Build && prove --blib t/*pod-cover*.t");
