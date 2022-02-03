import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:smallbusiness/company/models.dart';
import 'package:smallbusiness/reusable/user_actions/models.dart';
import 'package:smallbusiness/reusable/user_actions/user_action.dart';

class WageSaveModel {
  final DocumentReference<DynamicMap> employeeRef;
  final DocumentReference<DynamicMap>? previousWageRef;
  final Wage wage;

  WageSaveModel(this.employeeRef, this.previousWageRef, this.wage);
}

class WageSaveAction extends UserAction<WageSaveModel> {
  final DateFormat dateFormat = DateFormat("yyyyMMdd");
  WageSaveAction(
      FirebaseFirestore firestore, DocumentReference<Object?> userRef)
      : super(firestore, userRef);

  @override
  Future<ActionResult> performActionInternal(WageSaveModel action) async {
    String docId = dateFormat.format(action.wage.validFrom);

    DocumentReference<DynamicMap> wageRef =
        queryBuilder.wagesCollection(action.employeeRef).doc(docId);
    if (action.previousWageRef != null) {
      await addUpdateToBatch(
          action.previousWageRef!, {"validTo": action.wage.validFrom});
    }
    DynamicMap data = action.wage.toJson();
    await addSetDataToBatch(wageRef, data, merge: true);
    return ActionResult.ok("wage_saved", wageRef, data);
  }
}
