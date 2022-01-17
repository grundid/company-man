part of 'invitation_cubit.dart';

@immutable
abstract class InvitationState {}

class InvitationInProgress extends InvitationState {}

class InvitationNotFound extends InvitationState {}

class InvitationDone extends InvitationState {}

class InvitationInitialized extends InvitationState {
  final Invitation invitation;
  final String invitationId;

  InvitationInitialized(this.invitation, this.invitationId);
}
