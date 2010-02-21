package Mail::Chimp::List;
use strict;
use warnings;

use Object::Tiny qw(_api id web_id name date_created member_count unsubscribe_count email_type_option
    default_from_name default_from_email default_subject default_language list_rating 
    member_count_since_send unsubscribe_since_send_count cleaned_count_since_send);


sub _call {
    my ( $self, $method, @args ) = @_;
    return $self->_api->_call( $method, $self->_api->api_key, $self->id, @args );
}

sub subscribe_member {
    my ( $self, $email, $merge_vars ) = @_;
    $merge_vars ||= {};
    return $self->_call( 'listSubscribe', $email, $merge_vars );
}

sub unsubscribe_member {
    my ( $self, $email, $delete ) = @_;
    return $self->_call( 'listUnsubscribe', $email, $delete );
}

sub update_member {
    my ( $self, $email, $merge_vars, $email_type, $replace_interests ) = @_;
    $merge_vars ||= {};
    return $self->_call( 'listUpdateMember', $email, $merge_vars, $email_type, $replace_interests );
}

sub members {
    my ( $self, $status, $since, $start, $limit ) = @_;
    return $self->_call( 'listMembers', $status, $since, $start, $limit );
}

sub member_info {
    my ( $self, $email ) = @_;
    return $self->_call( 'listMemberInfo', $email );
}

sub merge_vars {
    my ( $self ) = @_;
    return $self->_call( 'listMergeVars' );
}

sub add_merge_var {
    my ( $self, $name, $description, $options ) = @_;
    return $self->_call( 'listMergeVarAdd', uc $name, $description, $options );
}

sub delete_merge_var {
    my ( $self, $name ) = @_;
    return $self->_call( 'listMergeVarDel', uc $name );
}

sub update_merge_var {
    my ( $self, $name ) = @_;
    return $self->_call( 'listMergeVarUpdate', uc $name );
}

sub webhooks {
    my ( $self ) = @_;
    return $self->_call('listWebhooks' );
}

sub add_webhook {
    my ( $self, $url, $actions, $sources ) = @_;
    return $self->_call( 'listWebhookAdd', $url, $actions, $sources );
}

sub delete_webhook {
    my ( $self, $url, $actions, $sources ) = @_;
    return $self->_call( 'listWebhookDel', $url );
}



1;
