import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/reusable/query_builder.dart';
import 'package:smallbusiness/user_actions/sign_in_user.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth auth;
  late StreamSubscription _authStateChanges;

  AuthCubit(this.auth) : super(AuthInProgress()) {
    _authStateChanges = auth.authStateChanges().listen((User? user) async {
      log("User changed: uid: ${user?.uid}");
      if (user != null) {
        emit(AuthInProgress());
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        QueryBuilder queryBuilder = QueryBuilder(firestore: firestore);

        //user.getIdToken(true);

        DocumentReference userRef =
            queryBuilder.usersCollection().doc(user.uid);
        DocumentSnapshot userSnapshot = await userRef.get();
        if (userSnapshot.exists) {
          // read user
        } else {
          SignInUserAction action = SignInUserAction(firestore, userRef);
          await action.performAction(SignInUserModel(userRef));
        }

        emit(AuthInitialized(
            SbmContext(user: SbmUser(user), firestore: firestore)));
      } else {
        emit(AuthNotLoggedIn());
      }
    });
  }

  signIn() {
    log("Sign in now");
    auth.signInAnonymously();
  }

  @override
  Future<void> close() async {
    await _authStateChanges.cancel();
    return super.close();
  }
}
