#! /usr/bin/perl -w

use strict;
use warnings;

use WWW::Mechanize;
use Config::Pit;
use Web::Scraper;
use Encode;
use YAML;

my $config = pit_get('mixi.jp', require => {
    "mailaddress" => 'your mailaddress on mixi.jp',
    "password" => 'your password on mixi.jp'
});

## mixiにログイン
my $url = 'http://mixi.jp/';
my $mech = WWW::Mechanize->new();
$mech->get($url);
$mech->submit_form(
    fields => {
        email => $config->{'mailaddress'},
        password => $config->{'password'},
    },
);
$mech->get('http://mixi.jp/home.pl');

## チェックのページに移動
$mech->follow_link(url_regex => qr{recent_check\.pl});

## チェックされたリンクに関する情報を取得
my $scraper = scraper {
    process "li.listItem", "checks[]" => scraper {
        process ".title > a", title => '@alt';
        process ".name > a", user => 'TEXT';
        process ".title > a", link => '@href';
    };
};
my $res = $scraper->scrape($mech->content, $mech->uri);

## feed化
my $feed = {
    title => "mixi recent check",
    link => $mech->uri,
    entries => [],
};

for my $check (@{$res->{checks}}) {
    # entryを作成
    my $entry = {
        title => $check->{user},
        body => $check->{title},
        link => $check->{link},
    };

    push @{$feed->{entries}}, $entry;
}
binmode STDOUT, ":utf8";
print YAML::Dump $feed;

