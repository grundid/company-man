import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smallbusiness/reusable/user_actions/models.dart';
import 'package:smallbusiness/reusable/user_actions/user_action.dart';

class InviteAcceptModel {
  final String inviteId;

  InviteAcceptModel(this.inviteId);
}

class InviteAcceptAction extends UserAction<InviteAcceptModel> {
  InviteAcceptAction(
      FirebaseFirestore firestore, DocumentReference<Object?> userRef)
      : super(firestore, userRef);

  @override
  Future<ActionResult> performActionInternal(InviteAcceptModel action) async {
    final inviteAcceptRef = queryBuilder.invitationResponsesCollection().doc();

    DynamicMap data = {
      "userRef": userRef,
      "inviteId": action.inviteId,
      "status": "accepted"
    };

    await addSetDataToBatch(inviteAcceptRef, data);
    return ActionResult.ok("invite_accepted", inviteAcceptRef, data);
  }
}
