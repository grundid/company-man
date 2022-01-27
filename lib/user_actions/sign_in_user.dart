import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smallbusiness/reusable/user_actions/models.dart';
import 'package:smallbusiness/reusable/user_actions/user_action.dart';

class SignInUserModel {
  final DocumentReference<DynamicMap> userRef;
  final DateTime anonReminder;
  SignInUserModel(this.userRef, this.anonReminder);
}

class SignInUserAction extends UserAction<SignInUserModel> {
  SignInUserAction(
      FirebaseFirestore firestore, DocumentReference<DynamicMap?> userRef)
      : super(firestore, userRef);

  @override
  Future<ActionResult> performActionInternal(SignInUserModel action) async {
    final userRef = action.userRef;
    DynamicMap data = {
      "termsAccepted": Timestamp.now(),
      "privacyAccepted": Timestamp.now(),
      "anonReminder": Timestamp.fromDate(action.anonReminder)
    };
    await addSetDataToBatch(userRef, data);

    return ActionResult.ok("user_created", userRef, data);
  }
}
