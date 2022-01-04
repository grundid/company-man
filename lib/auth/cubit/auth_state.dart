part of 'auth_cubit.dart';

@immutable
abstract class AuthState {}

class AuthInProgress extends AuthState {}

class AuthInitialized extends AuthState {
  final User user;

  AuthInitialized(this.user);
}
