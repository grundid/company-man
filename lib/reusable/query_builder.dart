import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smallbusiness/reusable/object_role.dart';
import 'package:smallbusiness/reusable/user_actions/models.dart';

class QueryBuilder {
  final FirebaseFirestore firestore;
  final String logsPath;
  final String usersPath;

  QueryBuilder({
    required this.firestore,
    this.logsPath = "logs",
    this.usersPath = "users",
  });

  CollectionReference<DynamicMap> logsCollection() {
    return firestore.collection(logsPath);
  }

  CollectionReference<DynamicMap> usersCollection() {
    return firestore.collection(usersPath);
  }

  DocumentReference<ObjectRole> objectRoleRef(
      DocumentReference userRef, DocumentReference objectRef) {
    return userRef.collection("objectRoles").doc(objectRef.id).withConverter(
          fromFirestore: (snapshot, options) =>
              ObjectRole.fromMap(snapshot.data()!),
          toFirestore: (value, options) => value.toMap(),
        );
  }

  CollectionReference<DynamicMap> companiesCollection() {
    return firestore.collection("companies");
  }

  DocumentReference<DynamicMap> companyRef(String id) {
    return companiesCollection().doc(id);
  }
}
