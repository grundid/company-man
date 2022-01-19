import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smallbusiness/reusable/user_actions/models.dart';
import 'package:smallbusiness/reusable/user_actions/user_action.dart';
import 'package:smallbusiness/time_recording/models.dart';

class TimeRecordingSaveModel {
  final DocumentReference<DynamicMap>? timeRecordingRef;
  final TimeRecording timeRecording;

  TimeRecordingSaveModel(this.timeRecordingRef, this.timeRecording);
}

class TimeRecordingSaveAction extends UserAction<TimeRecordingSaveModel> {
  TimeRecordingSaveAction(
      FirebaseFirestore firestore, DocumentReference<Object?> userRef)
      : super(firestore, userRef);

  @override
  Future<ActionResult> performActionInternal(
      TimeRecordingSaveModel action) async {
    final timeRecordingRef = action.timeRecordingRef ??
        queryBuilder.timeRecordingsCollection().doc();
    DynamicMap data = action.timeRecording.toJson();
    await addSetDataToBatch(timeRecordingRef, data, merge: true);
    return ActionResult.ok("time_recording_saved", timeRecordingRef, data);
  }
}
