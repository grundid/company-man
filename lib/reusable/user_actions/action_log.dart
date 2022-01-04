import 'package:cloud_firestore/cloud_firestore.dart';

class ActionLog {
  String type;
  DocumentReference? reference;
  DateTime created;
  DocumentReference userRef;
  Map<String, dynamic>? content;

  ActionLog({
    required this.type,
    required this.reference,
    required this.created,
    required this.userRef,
    required this.content,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> result = {};
    result["type"] = type;
    result["reference"] = reference;
    result["created"] = created;
    result["userRef"] = userRef;
    result["content"] = content;
    return result;
  }
}
