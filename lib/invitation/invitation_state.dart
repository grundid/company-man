part of 'invitation_cubit.dart';

@immutable
abstract class InvitationState {}

class InvitationInProgress extends InvitationState {}

class InvitationNotFound extends InvitationState {
  final String enteredInvitationId;

  InvitationNotFound(this.enteredInvitationId);
}

class InvitationDone extends InvitationState {}

class InvitationInitialized extends InvitationState {
  final Invitation invitation;
  final String invitationId;

  InvitationInitialized(this.invitation, this.invitationId);
}
