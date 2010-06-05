package Plagger::Plugin::Notify::IphoneViaImKayac;
use strict;
use base qw( Plagger::Plugin );

use LWP::UserAgent;
use HTTP::Request::Common;

sub register {
    my($self, $context) = @_;
    $context->register_hook(
	$self,
	'plugin.init' => \&initialize,
	'publish.feed' => \&notify,
	);
}

sub initialize {
    my($self, $context) = @_;

    $self->conf->{username} or Plagger::context->error("username is required");    
}

sub notify {
    my($self, $context, $args) = @_;

    return if $args->{feed}->count == 0;

    my $feed = $args->{feed};
    my $subject = $feed->title || '(no-title)';

    my $cfg = $self->conf;
    my $postto = 'http://im.kayac.com/api/post/' . $cfg->{username};
    $context->log(info => "Post these messages to $postto : $subject");

    my %postdata = ();
    
    my $all_msg = $subject;
    foreach my $entry ( $feed->entries ) {
	$all_msg = join("\n", $all_msg, $entry->title);
    }
    $postdata{message} = $all_msg;

    my $password = $cfg->{password} or '';
    if( $password ) { $postdata{password} = $password; }

    my $handler = $cfg->{handler} or '';
    if( $handler ) { $postdata{handler} = $handler; }

    my $sig = $cfg->{sig} or '';
    if( $sig ) { $postdata{sig} = $sig; }

    my $request = POST($postto, \%postdata);

    my $ua = LWP::UserAgent->new;
    my $res = $ua->request($request);

    unless ($res->is_success) {
	$context->error("Post failed : $res->content");
    } else {
	$context->log(info => $res->content);
    }
}

1;
