part of 'employee_user_cubit.dart';

@immutable
abstract class EmployeeUserState {}

class EmployeeUserInProgress extends EmployeeUserState {}

class EmployeeUserInitialized extends EmployeeUserState {
  final DocumentReference<DynamicMap> objectRoleRef;
  final DynamicMap formValues;

  EmployeeUserInitialized(this.objectRoleRef, this.formValues);
}

class EmployeeUserNoUser extends EmployeeUserState {}

class EmployeeUserInvitationAvailable extends EmployeeUserState {
  final String inviteId;

  EmployeeUserInvitationAvailable(this.inviteId);
}
