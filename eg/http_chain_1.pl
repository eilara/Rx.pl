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
use Reactive::Observable::HttpClient qw(http_get);

# sequential chaining of HTTP requests, where each depends on the
# previous request, useful for drill-down

# we look for the Perl 6 page, extract the 5th link
# get the page for that link, and extract the 5th link
# then do it two more times, until we are 4 links away from
# Perl 6

my $Wikipedia = 'http://en.wikipedia.org/w/api.php';
my $Links     = "$Wikipedia?action=query&prop=links&format=json".
                "&pllimit=10&titles=";

sub decode_5th_link
    { shift->{query}->{pages}->values->[0]->{links}->[5]->{title} }

sub get_5th_link {
    my $page = uri_escape shift;
    Observable->from_http_get("$Links$page")
              ->map(sub{ decode_json $_->body })
              ->map(\&decode_5th_link);
}

get_5th_link('Perl 6')->expand(\&get_5th_link)
                      ->take(4)
                      ->foreach(
                            on_next  => sub { say },
                            on_error => sub { say },
                        );
