# -*- perl -*-

# t/002_basic.t - login

use Test::More;
use Data::Dumper;

unless ( $ENV{MAILCHIMP_USERNAME} and $ENV{MAILCHIMP_PASSWORD} ) {
    plan skip_all => 'Provide $ENV{MAILCHIMP_USERNAME} and $ENV{MAILCHIMP_PASSWORD} to run basic tests';
}
else {
    plan 'no_plan';
}

use_ok( 'Mail::Chimp::API' );

my $chimp = Mail::Chimp::API->new( username => $ENV{MAILCHIMP_USERNAME}, password => $ENV{MAILCHIMP_PASSWORD} );
my $lists = $chimp->lists;
diag(Dumper $lists);
