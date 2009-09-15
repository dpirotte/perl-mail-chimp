package Mail::Chimp::API;
use Moose;

our $VERSION = '0.12';

=head1 NAME

Mail::Chimp::API - Perl wrapper around the Mailchimp API

=head1 SYNOPSIS

  use strict;
  use Mail::Chimp::API;

  my $chimp = Mail::Chimp::API->new(apikey      => $apikey,
                                    api_version => 1.2);

  # or if you have no apikey setup:
  # my $chimp = Mail::Chimp::API->new(username    => $username,
  #                                   password    => $password,
  #                                   api_version => 1.1,
  #                                  );

  my $apikey      = $chimp->apikey;   # generated on first login if none was setup

  my $campaigns   = $chimp->campaigns;
  my $lists       = $chimp->lists;
  my $subscribers = $chimp->listMembers($lists->[0]->{id});

  print 'success' if $chimp->listSubscribe($lists->[0]->{id}, 'someone@somewhere.com', {}, 1);

=head1 DESCRIPTION

Mail::Chimp::API is a simple Perl wrapper around the MailChimp API.
The object exposes the MailChimp XML-RPC methods and confesses
fault codes/messages when errors occur.  Further, it keeps track of
your API key for you so you do not need to enter it each time.

Method parameters are passed straight through, in order, to MailChimp.
Thus, you do need to understand the MailChimp API as documented
at <http://api.mailchimp.com/> so that you will know the
appropriate parameters to pass to each method.

This API has been tested with version 1.0 and 1.1 of the API.

=head1 NOTES

If you find yourself getting '-32602' errors, you are probably missing
a required (even if empty) hash.  The API documentation should be your
first destination to verify the validity of your parameters.  For
example:

  # MailChimp Error -32602: server error. invalid method parameters
  print 'fail'    if $chimp->listSubscribe($lists->[0]->{id}, 'someone@somewhere.com');
  
  # The {} is required by MailChimp to indicate that you do not want any MergeVars
  print 'success' if $chimp->listSubscribe($lists->[0]->{id}, 'someone@somewhere.com', {}, 1);


=head1 DEPENDENCIES

  Mouse
  XMLRPC::Lite

=head1 SEE ALSO

  XMLRPC::Lite
  <http://www.mailchimp.com/api/1.2/>

=head1 COPYRIGHT

Copyright (C) 2009 Dave Pirotte.  All rights reserved.

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=head1 AUTHOR

Dave Pirotte (dpirotte@gmail.com)

Drew Taylor (drew@drewtaylor.com)

Ask Bjørn Hansen (ask@develooper.com)

=cut

use XMLRPC::Lite;

has 'username'    => (is => 'ro', isa => 'Str');
has 'password'    => (is => 'ro', isa => 'Str');
has 'apikey'      => (is => 'rw', isa => 'Str');
has 'api'         => (is => 'rw', isa => 'XMLRPC::Lite');
has 'api_version' => (is => 'ro', isa => 'Num', required => 1);
has 'api_url'     => (is => 'rw', isa => 'Str');
has 'use_secure'  => (is => 'rw', isa => 'Bool', default => 1);

sub BUILD {
  my $self = shift;

  die 'apikey or username and password is required'
    unless ($self->apikey or ($self->username and $self->password));

  my $protocol = 'http';
  $protocol .= 's' if $self->use_secure();
  $self->api_url( "$protocol://api.mailchimp.com/" . $self->api_version() . '/' );
  $self->api( XMLRPC::Lite->proxy( $self->api_url() ) );

  unless ($self->apikey) {
      $self->apikey( $self->_call( 'login', $self->username(), $self->password() ) );
  }
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
    *{"${class}::$method"} = sub { my $self = shift; $self->_call( $method, $self->apikey, @_ ) };
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
  getAccountDetails
  inlineCss
  ping

  listBatchSubscribe
  listBatchUnsubscribe
  listInterestGroupAdd
  listInterestGroupDel
  listInterestGroups
  listInterestGroupsUpdate
  listMemberInfo
  listMembers
  listMergeVarAdd
  listMergeVarDel
  listMergeVars
  listMergeVarsUpdate
  listSubscribe
  listUnsubscribe
  listUpdateMember
  listWebhookAdd
  listWebhookDel
  listWebhooks
  lists
);

__PACKAGE__->_make_api_method( $_ ) for @api_methods;



1;
