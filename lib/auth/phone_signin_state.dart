part of 'phone_signin_cubit.dart';

@immutable
abstract class PhoneSignInState {}

class PhoneSignInInProgress extends PhoneSignInState {}

class PhoneSignInVerified extends PhoneSignInState {
  final bool linked;

  PhoneSignInVerified(this.linked);
}

class PhoneSignInAlreadyInUse extends PhoneSignInState {
  final PhoneAuthCredential credential;

  PhoneSignInAlreadyInUse(this.credential);
}

class PhoneSignInInvalidCode extends PhoneSignInState {
  final int? forceResendingToken;

  PhoneSignInInvalidCode(this.forceResendingToken);
}

class PhoneSignInError extends PhoneSignInState {
  final String message;

  PhoneSignInError(this.message);
}

class PhoneSignInCodeSent extends PhoneSignInState {
  final String verificationId;
  final int? forceResendingToken;

  PhoneSignInCodeSent(this.verificationId, this.forceResendingToken);
}
