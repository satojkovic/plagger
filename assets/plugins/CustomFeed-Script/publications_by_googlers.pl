#! /usr/bin/perl 

use strict;
use warnings;

use Web::Scraper;
use URI;
use Encode;

## get publications list
my $url = 'http://research.google.com/pubs/papers.html';

my $scraper = scraper {
    process "/html/body/div/div[2]/ul/li", 'papers[]' => scraper {
        process "p", "info" => "TEXT";
        process "//p/a[1]", "link" => '@href';
        process "//p/a[1]", "author" => 'TEXT';
    };
};
my $res = $scraper->scrape( URI->new($url) );

for my $paper (@{$res->{papers}}) {
    $paper->{info} =~ /([^\[\]]+)/;
    print encode("utf8", $1) . "\n";
    print "$paper->{author} : $paper->{link}\n";
    print "\n";
}

## feed and entries
# my $feed = {
#     title => "Publications by Googlers",
#     link => $url,
#     entries => [],
# };

# for my $paper (@{$res->{papers}}) {

# }
