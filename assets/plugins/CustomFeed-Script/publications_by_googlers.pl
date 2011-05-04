#! /usr/bin/perl 

use strict;
use warnings;

use Web::Scraper;
use URI;
use YAML;

## get publications list
my $url = 'http://research.google.com/pubs/papers.html';

my $scraper = scraper {
    process "/html/body/div/div[2]/ul/li", 'papers[]' => scraper {
        process "p", "info" => 'TEXT';
        process "//p/a[1]", "link" => '@href';
        process "//p/a[1]", "author" => 'TEXT';
    };
};
my $res = $scraper->scrape( URI->new($url) );

## feed and entries
my $feed = {
    title => "Publications by Googlers",
    link => $url,
    entries => [],
};

for my $paper (@{$res->{papers}}) {
    # cut off brace
    $paper->{info} =~ /([^\[\]]+)/;

    my $entry = {
        title => $paper->{author},
        body => $1, 
        link => $paper->{link},
    };

    push @{$feed->{entries}}, $entry;
}

binmode STDOUT, ":utf8";
print YAML::Dump $feed;
