import 'package:cloud_firestore/cloud_firestore.dart';

class ObjectRole {
  final DocumentReference companyRef;
  final DocumentReference objectRef;
  final DocumentReference employeeDataRef;
  bool manager;
  bool employee;

  ObjectRole({
    required this.companyRef,
    required this.objectRef,
    required this.employeeDataRef,
    required this.manager,
    required this.employee,
  });
}
