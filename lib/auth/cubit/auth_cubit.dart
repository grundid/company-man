import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth auth;
  late StreamSubscription _authStateChanges;

  AuthCubit(this.auth) : super(AuthInProgress()) {
    _authStateChanges = auth.authStateChanges().listen((User? user) {
      print("User changed: uid: ${user?.uid}");
      if (user != null) {
        emit(AuthInitialized(user));
      } else {
        auth.signInAnonymously();
      }
    });
  }

  @override
  Future<void> close() async {
    await _authStateChanges.cancel();
    return super.close();
  }
}
