import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smallbusiness/company/models.dart';
import 'package:smallbusiness/reusable/object_role.dart';
import 'package:smallbusiness/reusable/user_actions/models.dart';
import 'package:smallbusiness/reusable/user_actions/user_action.dart';

class CompanySaveModel {
  final DocumentReference<DynamicMap>? companyRef;
  final Company company;

  CompanySaveModel(this.companyRef, this.company);
}

class CompanySaveAction extends UserAction<CompanySaveModel> {
  CompanySaveAction(
      FirebaseFirestore firestore, DocumentReference<Object?> userRef)
      : super(firestore, userRef);

  @override
  Future<ActionResult> performActionInternal(CompanySaveModel action) async {
    DocumentReference<DynamicMap> companyRef =
        action.companyRef ?? queryBuilder.companiesCollection().doc();
    DynamicMap data = action.company.toMap();
    await addSetDataToBatch(companyRef, data, merge: true);

    if (action.companyRef == null) {
      Employee employee = Employee(
          employeeNo: 1,
          person: Person(firstName: "Ich", lastName: ""),
          address: Address(street: "", no: "", postalCode: "", city: ""),
          email: null,
          phone: null);

      DocumentReference<DynamicMap> employeeRef =
          queryBuilder.employeesCollection(companyRef).doc();
      await addSetDataToBatch(employeeRef, employee.toJson());

      DocumentReference objectRoleRef =
          queryBuilder.objectRoleRef(userRef, companyRef);

      await addSetDataToBatch(
          objectRoleRef,
          ObjectRole(
                  companyRef: companyRef,
                  objectRef: companyRef,
                  employeeRef: employeeRef,
                  manager: true,
                  employee: true)
              .toJson());
      DynamicMap userData = {"companyRef": companyRef};
      await addUpdateToBatch(userRef, userData);
    }

    return ActionResult.ok("company_saved", companyRef, data);
  }
}
