import 'package:cloud_firestore/cloud_firestore.dart';

class QueryBuilder {
  final FirebaseFirestore firestore;
  final String logsPath;
  final String usersPath;
  QueryBuilder({
    required this.firestore,
    this.logsPath = "logs",
    this.usersPath = "users",
  });

  CollectionReference logsCollection() {
    return firestore.collection(logsPath);
  }

  CollectionReference usersCollection() {
    return firestore.collection(usersPath);
  }
}
