import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:smallbusiness/reusable/user_actions/models.dart';
import 'package:smallbusiness/reusable/user_actions/user_action.dart';

class WageDeleteModel {
  final DocumentReference<DynamicMap> wageRef;
  final DocumentReference<DynamicMap>? previousWageRef;

  WageDeleteModel(this.wageRef, this.previousWageRef);
}

class WageDeleteAction extends UserAction<WageDeleteModel> {
  final DateFormat dateFormat = DateFormat("yyyyMMdd");
  WageDeleteAction(
      FirebaseFirestore firestore, DocumentReference<Object?> userRef)
      : super(firestore, userRef);

  @override
  Future<ActionResult> performActionInternal(WageDeleteModel action) async {
    logging = true;
    if (action.previousWageRef != null) {
      await addUpdateToBatch(action.previousWageRef!, {"validTo": null});
    }
    await addDeleteToBatch(action.wageRef);
    return ActionResult.ok("wage_deleted", action.wageRef, {});
  }
}
