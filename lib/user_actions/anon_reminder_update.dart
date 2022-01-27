import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smallbusiness/reusable/user_actions/models.dart';
import 'package:smallbusiness/reusable/user_actions/user_action.dart';

class AnonReminderUpdateModel {
  final DocumentReference<DynamicMap> userRef;
  final DateTime anonReminder;
  AnonReminderUpdateModel(this.userRef, this.anonReminder);
}

class AnonReminderUpdateAction extends UserAction<AnonReminderUpdateModel> {
  AnonReminderUpdateAction(
      FirebaseFirestore firestore, DocumentReference<DynamicMap?> userRef)
      : super(firestore, userRef);

  @override
  Future<ActionResult> performActionInternal(
      AnonReminderUpdateModel action) async {
    final userRef = action.userRef;
    DynamicMap data = {"anonReminder": Timestamp.fromDate(action.anonReminder)};
    await addUpdateToBatch(userRef, data);

    return ActionResult.ok("anon_reminder_updated", userRef, data);
  }
}
