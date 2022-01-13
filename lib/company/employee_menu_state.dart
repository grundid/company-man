part of 'employee_menu_cubit.dart';

@immutable
abstract class EmployeeMenuState {}

class EmployeeMenuInProgress extends EmployeeMenuState {}

class EmployeeMenuInitialized extends EmployeeMenuState {
  final Employee employee;

  EmployeeMenuInitialized(this.employee);
}
