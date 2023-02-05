import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/invitation/models.dart';
import 'package:smallbusiness/reusable/user_actions/models.dart';
import 'package:smallbusiness/user_actions/invite_accept.dart';

part 'invitation_state.dart';

class InvitationCubit extends Cubit<InvitationState> {
  final SbmContext sbmContext;
  final String invitationId;
  StreamSubscription? subscription;

  InvitationCubit(this.sbmContext, this.invitationId)
      : super(InvitationInProgress()) {
    _init();
  }

  _init() async {
    final snapshots = await sbmContext.queryBuilder
        .invitationsCollection()
        .where("inviteId", isEqualTo: invitationId)
        .get();
    if (snapshots.size == 0) {
      emit(InvitationNotFound(invitationId));
    } else {
      DocumentSnapshot<DynamicMap> invitationSnapshot = snapshots.docs.first;
      Invitation invitation = Invitation.fromJson(invitationSnapshot.data()!);
      emit(InvitationInitialized(invitation, invitationId));
    }
  }

  Future<void> accept() async {
    emit(InvitationInProgress());
    InviteAcceptModel model = InviteAcceptModel(invitationId);

    InviteAcceptAction action =
        InviteAcceptAction(sbmContext.firestore, sbmContext.userRef);

    ActionResult actionResult = await action.performAction(model);

    subscription = actionResult.actionReference!
        .snapshots()
        .listen((DocumentSnapshot<DynamicMap> snapshot) {
      String status = snapshot.data()!["status"];
      if (status == "done") {
        emit(InvitationDone());
      }
    });
  }

  @override
  Future<void> close() {
    subscription?.cancel();
    return super.close();
  }
}
