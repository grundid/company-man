import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smallbusiness/reusable/user_actions/models.dart';
import 'package:smallbusiness/reusable/user_actions/user_action.dart';

class ObjectRoleDeleteModel {
  final DocumentReference<DynamicMap> objectRoleRef;

  ObjectRoleDeleteModel(this.objectRoleRef);
}

class ObjectRoleDeleteAction extends UserAction<ObjectRoleDeleteModel> {
  ObjectRoleDeleteAction(
      FirebaseFirestore firestore, DocumentReference<Object?> userRef)
      : super(firestore, userRef);

  @override
  Future<ActionResult> performActionInternal(
      ObjectRoleDeleteModel action) async {
    await addDeleteToBatch(action.objectRoleRef);
    return ActionResult.ok("object_role_deleted", action.objectRoleRef, {});
  }
}
