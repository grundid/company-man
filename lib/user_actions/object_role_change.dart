import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smallbusiness/reusable/user_actions/models.dart';
import 'package:smallbusiness/reusable/user_actions/user_action.dart';

class ObjectRoleSaveModel {
  final DocumentReference<DynamicMap> objectRoleRef;
  final DocumentReference<DynamicMap> companyRef;
  final bool employee;
  final bool manager;

  ObjectRoleSaveModel(
      this.objectRoleRef, this.companyRef, this.employee, this.manager);
}

class ObjectRoleSaveAction extends UserAction<ObjectRoleSaveModel> {
  ObjectRoleSaveAction(
      FirebaseFirestore firestore, DocumentReference<Object?> userRef)
      : super(firestore, userRef);

  @override
  Future<ActionResult> performActionInternal(ObjectRoleSaveModel action) async {
    DynamicMap data = {
      "employee": action.employee,
      "manager": action.manager,
      "companyRef": action.companyRef,
    };

    await addUpdateToBatch(action.objectRoleRef, data);
    return ActionResult.ok("object_role_updated", action.objectRoleRef, data);
  }
}
