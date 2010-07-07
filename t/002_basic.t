# -*- perl -*-

# t/002_basic.t - login
use strict;
use warnings;
use Test::More;
use Data::Dumper;

unless ( $ENV{MAILCHIMP_APIKEY} ) {
    plan skip_all => 'Provide $ENV{MAILCHIMP_APIKEY} to run basic tests';
}
else {
    plan 'no_plan';
}

use_ok( 'Mail::Chimp::API' );

my $chimp = Mail::Chimp::API->new( api_key => $ENV{MAILCHIMP_APIKEY}, debug => $ENV{MAILCHIMP_DEBUG} );

my $lists = $chimp->all_lists();

{
    my $list = $lists->[0];
    diag("List name: ".$list->name);
    my $email = 'drew@drewtaylor.com';
    # my $vars = {};
    my $success = $list->subscribe_address( $email );
    diag("Added $email: $success");
}
