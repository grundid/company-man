import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smallbusiness/reusable/user_actions/models.dart';
import 'package:smallbusiness/reusable/user_actions/user_action.dart';

class NotificationTokenSaveModel {
  final String token;

  NotificationTokenSaveModel(this.token);
}

class NotificationTokenSaveAction
    extends UserAction<NotificationTokenSaveModel> {
  NotificationTokenSaveAction(
      FirebaseFirestore firestore, DocumentReference<DynamicMap?> userRef)
      : super(firestore, userRef);

  @override
  Future<ActionResult> performActionInternal(
      NotificationTokenSaveModel action) async {
    CollectionReference<DynamicMap> collection = userRef.collection("tokens");

    QuerySnapshot querySnapshot =
        await collection.where("token", isEqualTo: action.token).get();

    if (querySnapshot.size == 0) {
      Map<String, dynamic> data = {
        'token': action.token,
      };

      DocumentReference<DynamicMap> tokenRef = collection.doc();
      await addSetDataToBatch(tokenRef, data);
      return ActionResult.ok("create_notification_token", tokenRef, data);
    } else {
      return ActionResult.emptyOk();
    }
  }
}
