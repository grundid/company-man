part of 'auth_cubit.dart';

@immutable
abstract class AuthState {}

class AuthInProgress extends AuthState {}

class AuthNotLoggedIn extends AuthState {}

class AuthInitialized extends AuthState {
  final SbmContext sbmContext;

  AuthInitialized(this.sbmContext);
}
