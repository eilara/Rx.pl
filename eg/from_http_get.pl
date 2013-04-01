#!/usr/bin/perl

use v5.10;
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use URI::Escape;
use Reactive;
use Reactive::Observable::HttpClient; # for HttpClient observables

my $Query     = uri_escape 'Perl 6';
my $Wikipedia = 'http://en.wikipedia.org/w/api.php';
my $Perl6     = "$Wikipedia?action=query&list=search&format=json".
                "&srsearch=$Query&srlimit=1";

say "Getting $Perl6...\n";                

Observable->from_http_get($Perl6)->foreach(
    on_next  => sub { use Data::Dumper;print Dumper [@_] },
    on_error => sub { say $_->{ErrorMessage} },
);

say 'Done.';
