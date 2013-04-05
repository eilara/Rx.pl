#!/usr/bin/perl

use v5.10;
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use URI::Escape;
use JSON;
use Reactive;
use Reactive::Observable::HttpClient; # for HttpClient observables

my $Query     = uri_escape 'Perl 6';
my $Wikipedia = 'http://en.wikipedia.org/w/api.php';
my $Perl6     = "$Wikipedia?action=query&list=search&format=json".
                "&srsearch=$Query&srlimit=1";

my $json = JSON->new->pretty;

say "Getting $Perl6...";

Observable->from_http_get($Perl6)->foreach(
    on_next  => sub { say $json->encode(decode_query($_)) },
    on_error => sub { say $_->{ErrorMessage} },
);

say 'Done.';

sub decode_query {
    $json->decode(shift->body)->{query}
                              ->{search}
                              ->[0];
}

