part of 'employee_wage_list_cubit.dart';

@immutable
abstract class EmployeeWageListState {}

class EmployeeWageListInProgress extends EmployeeWageListState {}

class EmployeeWageListInitialized extends EmployeeWageListState {
  final List<Wage> wages;
  final DateTime? firstDate;
  final DateTime initialDate;
  final Wage? lastWage;
  final Wage? previousWage;

  EmployeeWageListInitialized(this.wages, this.firstDate, this.initialDate,
      this.lastWage, this.previousWage);
}
