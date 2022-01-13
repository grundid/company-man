import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smallbusiness/company/models.dart';
import 'package:smallbusiness/reusable/user_actions/models.dart';
import 'package:smallbusiness/reusable/user_actions/user_action.dart';

class EmployeeSaveModel {
  final DocumentReference<DynamicMap> companyRef;
  final DocumentReference<DynamicMap>? employeeRef;
  final Employee employee;

  EmployeeSaveModel(this.companyRef, this.employeeRef, this.employee);
}

class EmployeeSaveAction extends UserAction<EmployeeSaveModel> {
  EmployeeSaveAction(
      FirebaseFirestore firestore, DocumentReference<Object?> userRef)
      : super(firestore, userRef);

  @override
  Future<ActionResult> performActionInternal(EmployeeSaveModel action) async {
    DocumentReference<DynamicMap> employeeRef = action.employeeRef ??
        queryBuilder.employeesCollection(action.companyRef).doc();
    DynamicMap data = action.employee.toJson();
    await addSetDataToBatch(employeeRef, data, merge: true);
    return ActionResult.ok("employee_saved", employeeRef, data);
  }
}
