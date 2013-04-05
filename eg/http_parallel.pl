#!/usr/bin/perl

use v5.10;
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use autobox::Core;
use URI::Escape;
use JSON;
use Reactive;
use Reactive::Observable::HttpClient; # for HttpClient observables

# get 3 snippets in parallel, say them as they arrive

my @Queries   = ('Perl 6', 'Perl 5', 'Z shell');
my $Wikipedia = 'http://en.wikipedia.org/w/api.php';
my $Url       = "$Wikipedia?action=query&list=search&format=json".
                "&srlimit=1&srsearch=";

sub decode_query($)
    { decode_json (shift->body)->{query}->{search}->[0]->{snippet} }

sub get_summary($) { Observable->from_http_get($Url. shift) }

Observable->merge(
    
    [@Queries]->map(sub{ uri_escape  $_ })
              ->map(sub{ get_summary $_ })

)->map(sub{ decode_query $_ })->foreach(

    on_next  => sub { say },
    on_error => sub { say },

);

say 'Done.';


