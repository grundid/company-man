import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SbmUser {
  final User _user;

  String get uid => _user.uid;
  bool get isAnonymous => _user.isAnonymous;

  SbmUser(this._user);
}

class SbmContext {
  final SbmUser user;
  final FirebaseFirestore firestore;
  SbmContext({required this.user, required this.firestore});
}
