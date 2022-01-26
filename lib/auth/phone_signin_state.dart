part of 'phone_signin_cubit.dart';

@immutable
abstract class PhoneSigninState {}

class PhoneSigninInProgress extends PhoneSigninState {}

class PhoneSigninVerified extends PhoneSigninState {}

class PhoneSigninError extends PhoneSigninState {
  final String message;

  PhoneSigninError(this.message);
}

class PhoneSigninCodeSent extends PhoneSigninState {
  final String verificationId;
  final int? forceResendingToken;

  PhoneSigninCodeSent(this.verificationId, this.forceResendingToken);
}
