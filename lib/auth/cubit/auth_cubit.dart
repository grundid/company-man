import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/reusable/object_role.dart';
import 'package:smallbusiness/reusable/query_builder.dart';
import 'package:smallbusiness/reusable/user_actions/models.dart';
import 'package:smallbusiness/user_actions/sign_in_user.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth auth;
  final SbmContext sbmContext;
  late StreamSubscription _authStateChanges;

  AuthCubit(this.sbmContext, this.auth) : super(AuthInProgress()) {
    _authStateChanges = auth.authStateChanges().listen((User? user) async {
      log("User changed: uid: ${user?.uid}");
      if (user != null) {
        emit(AuthInProgress());
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        QueryBuilder queryBuilder = QueryBuilder(firestore: firestore);

        //user.getIdToken(true);
        ObjectRole? objectRole;
        DocumentReference<DynamicMap> userRef =
            queryBuilder.usersCollection().doc(user.uid);
        DocumentSnapshot<DynamicMap> userSnapshot = await userRef.get();
        if (userSnapshot.exists) {
          // wir belassen companyRef um eventuell die companyRef
          // zu wechseln, falls es mehrere objectRoles gibt
          DocumentReference? companyRef = userSnapshot.data()!["companyRef"];
          if (companyRef != null) {
            final userObjectRoleRef =
                queryBuilder.objectRoleRef(userRef, companyRef);
            DocumentSnapshot<DynamicMap> objectRoleSnapshot =
                await userObjectRoleRef.get();
            if (objectRoleSnapshot.exists) {
              objectRole = ObjectRole.fromJson(objectRoleSnapshot.data()!);
            }
          }
        } else {
          SignInUserAction action = SignInUserAction(firestore, userRef);
          await action.performAction(SignInUserModel(userRef));
        }

        sbmContext.init(SbmUser(userRef, objectRole, user), queryBuilder);

        emit(AuthInitialized(sbmContext));
      } else {
        emit(AuthNotLoggedIn());
      }
    });
  }

  updateUser() async {
    final userSnapshot = await sbmContext.userRef.get();
    DocumentReference? companyRef = userSnapshot.data()!["companyRef"];
    if (companyRef != null) {
      DocumentSnapshot<DynamicMap> objectRoleSnapshot = await sbmContext
          .queryBuilder
          .objectRoleRef(sbmContext.userRef, companyRef)
          .get();
      if (objectRoleSnapshot.exists) {
        sbmContext.user.objectRole =
            ObjectRole.fromJson(objectRoleSnapshot.data()!);
        emit(AuthInitialized(sbmContext));
      }
    }
  }

  signIn() {
    emit(AuthInProgress());
    log("Sign in now");
    auth.signInAnonymously();
  }

  @override
  Future<void> close() async {
    log("authcubit closed");
    await _authStateChanges.cancel();
    return super.close();
  }
}
