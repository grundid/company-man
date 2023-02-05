import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smallbusiness/reusable/object_role.dart';
import 'package:smallbusiness/reusable/query_builder.dart';
import 'package:smallbusiness/reusable/user_actions/models.dart';

class SbmUser {
  final DocumentReference<DynamicMap> userRef;
  ObjectRole? objectRole;
  final User user;
  final DateTime anonReminder;

  String get uid => user.uid;
  bool get isAnonymous => user.isAnonymous;

  bool get isManager => true == objectRole?.manager;
  bool get isEmployee => true == objectRole?.employee;

  bool get hasCompany => isManager || isEmployee;

  final String? displayName;
  final String? companyLabel;

  SbmUser(
      {required this.userRef,
      this.companyLabel,
      this.displayName,
      this.objectRole,
      required this.user,
      required this.anonReminder});
}

class SbmContext extends ChangeNotifier {
  late SbmUser user;
  final QueryBuilder queryBuilder;
  final FirebaseAuth auth;
  
  SbmContext(this.queryBuilder, this.auth);
  
  DocumentReference<DynamicMap> get userRef => user.userRef;
  FirebaseFirestore get firestore => queryBuilder.firestore;
  DocumentReference<DynamicMap>? get companyRef => user.objectRole?.companyRef;
  DocumentReference<DynamicMap>? get employeeRef =>
      user.objectRole?.employeeRef;

  init(SbmUser user) {
    this.user = user;
    notifyListeners();
  }
}
