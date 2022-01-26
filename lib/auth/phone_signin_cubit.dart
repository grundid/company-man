import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:smallbusiness/auth/app_context.dart';

part 'phone_signin_state.dart';

class PhoneSigninCubit extends Cubit<PhoneSigninState> {
  final SbmContext sbmContext;
  final String phoneNumber;
  PhoneSigninCubit(this.sbmContext, this.phoneNumber)
      : super(PhoneSigninInProgress()) {
    _signInWithPhoneNumber();
  }

  _signInWithPhoneNumber() {
    FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (phoneAuthCredential) {
        _linkWithCredential(phoneAuthCredential);
      },
      verificationFailed: (error) {
        log(error.toString());
        emit(PhoneSigninError(error.toString()));
      },
      codeSent: (verificationId, forceResendingToken) {
        emit(PhoneSigninCodeSent(verificationId, forceResendingToken));
      },
      codeAutoRetrievalTimeout: (verificationId) {
        log("codeAutoRetrievalTimeout");
        // emit(PhoneSigninCodeSent(verificationId, null));
      },
    );
  }

  void verifyCode(String verificationId, String code) {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: code);
    _linkWithCredential(credential);
  }

  _linkWithCredential(PhoneAuthCredential credential) {
    try {
      FirebaseAuth.instance.currentUser!.linkWithCredential(credential);
      emit(PhoneSigninVerified());
    } on FirebaseAuthException catch (e) {
      log(e.toString());
      if (e.code == "credential-already-in-use") {}
      emit(PhoneSigninError(e.toString()));
    }
  }
}
