package Mail::Chimp::API;
use Mouse;

our $VERSION = '0.12';

=head1 NAME

Mail::Chimp::API - Perl wrapper around the Mailchimp v1.1 API

=head1 SYNOPSIS

  use strict;
  use Mail::Chimp::API;

  my $chimp = Mail::Chimp::API->new(username => $username, password => $password);

  my $campaigns   = $chimp->campaigns;
  my $lists       = $chimp->lists;
  my $subscribers = $chimp->listMembers($lists->[0]->{id});

  print 'success' if $chimp->listSubscribe($lists->[0]->{id}, 'someone@somewhere.com', {}, 1);

=head1 DESCRIPTION

Mail::Chimp::API is a simple Perl wrapper around the MailChimp v1.1 API. The object exposes the MailChimp XML-RPC methods and confesses fault codes/messages when errors occur.  Further, it keeps track of your API key for you so you do not need to enter it each time.  

Method parameters are passed straight through, in order, to MailChimp.  Thus, you do need to understand the MailChimp v1.1 API as documented at <http://www.mailchimp.com/api/1.1/> so that you will know the appropriate parameters to pass to each method.

=head1 NOTES

If you find yourself getting '-32602' errors, you are probably missing a required (even if empty) hash.  The API documentation should be your first destination to verify the validity of your parameters.  For example:

  # MailChimp Error -32602: server error. invalid method parameters
  print 'fail'    if $chimp->listSubscribe($lists->[0]->{id}, 'someone@somewhere.com');
  
  # The {} is required by MailChimp to indicate that you do not want any MergeVars
  print 'success' if $chimp->listSubscribe($lists->[0]->{id}, 'someone@somewhere.com', {}, 1);

Also, the only security method implemented is login.  This is likely to change at some point in the future.

=head1 DEPENDENCIES

  Mouse
  XMLRPC::Lite

=head1 SEE ALSO

  XMLRPC::Lite
  <http://www.mailchimp.com/api/1.1/>

=head1 COPYRIGHT

Copyright (C) 2009 Dave Pirotte.  All rights reserved.

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=head1 AUTHOR

Dave Pirotte (dpirotte@gmail.com)

Drew Taylor (drew@drewtaylor.com)

=cut

use XMLRPC::Lite;

has 'username' => (is => 'ro', isa => 'Str', required => 1);
has 'password' => (is => 'ro', isa => 'Str', required => 1);
has 'key'      => (is => 'rw', isa => 'Str');
has 'api'      => (is => 'rw', isa => 'XMLRPC::Lite');
has 'api_version' => (is => 'ro', isa => 'Num', default => 1.1);
has 'api_url'     => (is => 'rw', isa => 'Str');
has 'use_secure'  => (is => 'rw', isa => 'Bool', default => 1);

sub BUILD {
  my $self = shift;
  my $protocol = 'http';
  $protocol .= 's' if $self->use_secure();
  $self->api_url( "$protocol://api.mailchimp.com/" . $self->api_version() . '/' );
  $self->api( XMLRPC::Lite->proxy( $self->api_url() ) );
  $self->key( $self->_call( 'login', $self->username(), $self->password() ) );
}

sub _call {
  my $self = shift;
  my $call = $self->api->call( @_ );
  return $call->result
    || confess( sprintf( "MailChimp Error %d: %s", $call->fault->{faultCode}, $call->fault->{faultString} ) );
}

{
  no strict 'refs';
  sub _make_api_method { 
    my ($class, $method) = @_;
    *{"${class}::$method"} = sub { my $self = shift; $self->_call( $method, $self->key, @_ ) };
  }
}

my @api_methods = qw(
  campaignContent
  campaignCreate
  campaignDelete
  campaignEcommAddOrder
  campaignFolders
  campaignPause
  campaignReplicate
  campaignResume
  campaignSchedule
  campaignSegmentTest
  campaignSendNow
  campaignSendTest
  campaignTemplates
  campaignUnschedule
  campaignUpdate
  campaigns
  
  campaignAbuseReports
  campaignClickStats
  campaignHardBounces
  campaignSoftBounces
  campaignStats
  campaignUnsubscribes
  
  campaignClickDetailAIM
  campaignEmailStatsAIM
  campaignEmailStatsAIMAll
  campaignNotOpenedAIM
  campaignOpenedAIM
  
  generateText
  getAffiliateInfo
  inlineCss
  ping

  listBatchSubscribe
  listBatchUnsubscribe
  listInterestGroupAdd
  listInterestGroupDel
  listInterestGroups
  listMemberInfo
  listMembers
  listMergeVarAdd
  listMergeVarDel
  listMergeVars
  listSubscribe
  listUnsubscribe
  listUpdateMember
  lists
);

__PACKAGE__->_make_api_method( $_ ) for @api_methods;



1;
