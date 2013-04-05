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

# get all links on Perl6 page, in batches, using Wikipedia
# 'continue' syntax to iterate over the results

# each response returns the 'continue' token that can be used
# to get the next batch of data, until the last response which
# has no token

# to get all links we need to chain HTTP requests until
# there are no more links left to get

my $Page      = 1146638; # id of Perl 6 page, 312769 is Givataim wgArticleId
my $Batch     = 20;      # get $Batch links in each batch
my $Wikipedia = 'http://en.wikipedia.org/w/api.php';
my $Links     = "$Wikipedia?action=query&prop=links&format=json".
                "&pageids=$Page&pllimit=$Batch";

sub decode_token { $_->{'query-continue'}->{links}->{plcontinue} }

sub decode_links {
    return [ map { $_->{title} }
                 @{$_->{query}->{pages}->{$Page}->{links}} ];
}

sub get_links {
    my $token = shift;
    my $continue = $token? "&plcontinue=$token": '';
    my $get = Observable->from_http_get($Links. $continue);
    return $get->map(sub{ decode_json $_->body })
               ->map(sub{ {token => decode_token, links => decode_links} });
}

get_links->expand(sub{
    $_->{token}? get_links($_->{token})
               : Observable->empty
})->foreach(
    on_next  => sub{ say for @{$_->{links}} },
    on_error => sub{ say },
);

__END__
format=json&action=query&titles=Perl%206&prop=links&pllimit=10
&plcontinue=1146638|0|Backward_compatibility
