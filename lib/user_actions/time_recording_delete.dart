import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smallbusiness/reusable/user_actions/models.dart';
import 'package:smallbusiness/reusable/user_actions/user_action.dart';

class TimeRecordingDeleteModel {
  final DocumentReference<DynamicMap> timeRecordingRef;

  TimeRecordingDeleteModel(this.timeRecordingRef);
}

class TimeRecordingDeleteAction extends UserAction<TimeRecordingDeleteModel> {
  TimeRecordingDeleteAction(
      FirebaseFirestore firestore, DocumentReference<Object?> userRef)
      : super(firestore, userRef);

  @override
  Future<ActionResult> performActionInternal(
      TimeRecordingDeleteModel action) async {
    await addDeleteToBatch(action.timeRecordingRef);
    return ActionResult.emptyOk();
  }
}
