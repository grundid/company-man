import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:smallbusiness/auth/app_context.dart';

part 'phone_signin_state.dart';

class PhoneSigninCubit extends Cubit<PhoneSignInState> {
  final SbmContext sbmContext;
  final String phoneNumber;
  final FirebaseAuth auth = FirebaseAuth.instance;
  int? forceResendingToken;

  PhoneSigninCubit(this.sbmContext, this.phoneNumber)
      : super(PhoneSignInInProgress()) {
    _signInWithPhoneNumber();
  }

  _signInWithPhoneNumber() {
    auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (phoneAuthCredential) {
          _linkWithCredential(phoneAuthCredential);
        },
        verificationFailed: (error) {
          log(error.toString());
          emit(PhoneSignInError(error.toString()));
        },
        codeSent: (verificationId, forceResendingToken) {
          this.forceResendingToken = forceResendingToken;
          emit(PhoneSignInCodeSent(verificationId, forceResendingToken));
        },
        codeAutoRetrievalTimeout: (verificationId) {
          log("codeAutoRetrievalTimeout");
        },
        forceResendingToken: forceResendingToken);
  }

  void verifyCode(String verificationId, String code) {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: code);
    _linkWithCredential(credential);
  }

  _linkWithCredential(PhoneAuthCredential credential) async {
    try {
      emit(PhoneSignInInProgress());
      if (auth.currentUser != null) {
        await auth.currentUser!.linkWithCredential(credential);
        emit(PhoneSignInVerified(true));
      } else {
        await auth.signInWithCredential(credential);
        emit(PhoneSignInVerified(false));
      }
    } on FirebaseAuthException catch (e) {
      log(e.toString());
      if (e.code == "credential-already-in-use") {
        emit(PhoneSignInAlreadyInUse(credential));
      } else if (e.code == "invalid-verification-code" ||
          e.code == "session-expired") {
        emit(PhoneSignInInvalidCode(forceResendingToken));
      } else if (e.code == "invalid-phone-number") {
        emit(PhoneSignInError(
            "Die Telefonnummer ist ungültig. Bitte geben Sie Ihre Telefonnummer im Format +49 123 1234567"));
      } else {
        emit(PhoneSignInError(e.toString()));
      }
    }
  }

  signOutAndRelogin(PhoneAuthCredential credential) async {
    emit(PhoneSignInInProgress());
    await auth.signOut();
    _linkWithCredential(credential);
  }

  resendCode(int forceResendingToken) {
    emit(PhoneSignInInProgress());
    this.forceResendingToken = forceResendingToken;
    _signInWithPhoneNumber();
  }
}
