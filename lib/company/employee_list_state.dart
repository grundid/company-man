part of 'employee_list_cubit.dart';

@immutable
abstract class EmployeeListState {}

class EmployeeListInProgress extends EmployeeListState {}

class EmployeeListInitialized extends EmployeeListState {
  final List<Employee> employees;

  EmployeeListInitialized(this.employees);
}
