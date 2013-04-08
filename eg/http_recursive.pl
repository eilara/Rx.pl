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

# get all links on Perl6 page, in batches, using Wikipedia
# 'continue' syntax to iterate over the results

# each response returns the 'continue' token that can be used
# to get the next batch of data, until the last response which
# has no token

# to get all links we need to chain HTTP requests until
# there are no more links left to get

my $Page      = 1146638; # id of Perl 6 page, wgArticleId=312769 for Givataim
my $Batch     = 20;      # get $Batch links in each batch
my $Wikipedia = 'http://en.wikipedia.org/w/api.php';
my $Links     = "$Wikipedia?action=query&prop=links&format=json".
                "&pageids=$Page&pllimit=$Batch";

# extract the 'continue' token from a JSON Wikipedia result
sub decode_token { $_->{'query-continue'}->{links}->{plcontinue} }

# extract the list of link titles from a JSON Wikipedia result
sub decode_links
    { [$_->{query}->{pages}->{$Page}->{links}->map(sub{ $_->{title} })] }

# takes token, returns stream firing hash of {next token, list of links}
sub get_links {
    my $token = shift;
    my $continue = $token? "&plcontinue=$token": '';
    my $get = Observable->from_http_get($Links. $continue);
    return $get->map(sub{ decode_json $_->body })
               ->map(sub{ {token => decode_token, links => decode_links} });
}

get_links->expand(sub{ get_links $_->{token} })
         ->take_until(sub{ !$_->{token} })
         ->foreach(
               on_next  => sub{ say for @{$_->{links}} },
               on_error => sub{ say },
           );


# another possible implementation:
#get_links->expand(sub{
#    $_->{token}? get_links($_->{token})
#               : Observable->empty # no more links
#})->foreach(
#    on_next  => sub{ say for @{$_->{links}} },
#    on_error => sub{ say },
#);
