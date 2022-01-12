import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smallbusiness/reusable/object_role.dart';
import 'package:smallbusiness/reusable/query_builder.dart';

class SbmUser {
  final DocumentReference userRef;
  final ObjectRole? objectRole;
  final User _user;

  String get uid => _user.uid;
  bool get isAnonymous => _user.isAnonymous;

  bool get isManager => true == objectRole?.manager;
  bool get isEmployee => true == objectRole?.employee;

  bool get hasCompany => isManager || isEmployee;

  SbmUser(this.userRef, this.objectRole, this._user);
}

class SbmContext extends ChangeNotifier {
  late SbmUser user;
  late QueryBuilder queryBuilder;
  SbmContext();

  DocumentReference get userRef => user.userRef;
  FirebaseFirestore get firestore => queryBuilder.firestore;

  init(SbmUser user, QueryBuilder queryBuilder) {
    this.user = user;
    this.queryBuilder = queryBuilder;
    notifyListeners();
  }
}
