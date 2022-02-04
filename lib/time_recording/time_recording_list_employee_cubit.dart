import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/company/models.dart';
import 'package:smallbusiness/reusable/user_actions/models.dart';
import 'package:smallbusiness/time_recording/models.dart';
import 'package:smallbusiness/time_recording/utils.dart';

part 'time_recording_list_employee_state.dart';

class MonthlySummary {
  final DateTime month;
  final String label;
  bool expanded = false;
  final List<MonthlySummaryPerEmployee> employees = [];

  MonthlySummary(this.month, this.label, {this.expanded = false});
}

class TimeRecordingWithWage {
  final TimeRecording timeRecording;
  final Wage? wage;

  TimeRecordingWithWage(this.timeRecording, this.wage);
}

class MonthlySummaryPerEmployee {
  final Employee employee;
  final HoursMinutes hoursMinutes = HoursMinutes.zero();
  int totalWageInCent = 0;
  final List<TimeRecordingWithWage> timeRecordings = [];

  MonthlySummaryPerEmployee(this.employee);

  void addTimeRecording(TimeRecordingWithWage timeRecordingWithWage) {
    timeRecordings.add(timeRecordingWithWage);
    Duration? duration = timeRecordingWithWage.timeRecording.duration();
    if (duration != null) {
      HoursMinutes durationInHoursMinutes = HoursMinutes.fromDuration(duration);
      hoursMinutes.add(durationInHoursMinutes);
      if (timeRecordingWithWage.wage != null) {
        totalWageInCent +=
            calculateWage(durationInHoursMinutes, timeRecordingWithWage.wage!);
      }
    }
  }
}

class TimeRecordingListEmployeeCubit
    extends Cubit<TimeRecordingListEmployeeState> {
  final SbmContext sbmContext;
  List<MonthlySummary> monthlySummaries = [];

  TimeRecordingListEmployeeCubit(this.sbmContext)
      : super(TimeRecordingListEmployeeInProgress()) {
    _init();
  }

  _init() async {
    List<Employee> employees = await _readEmployees();
    Map<String, List<Wage>> wagesPerEmployeePath = await _readWages();

    final queryTimeRecordings = await sbmContext.queryBuilder
        .timeRecordingsForCompanyRef(companyRef: sbmContext.companyRef!)
        .get();
    List<TimeRecording> timeRecordings = queryTimeRecordings.docs
        .map((e) => TimeRecording.fromSnapshot(e.reference, e.data()))
        .toList();

    Map<String, Employee> employeePerPath =
        Map.fromEntries(employees.map((e) => MapEntry(e.employeeRef!.path, e)));

    Map<DateTime, Map<String, List<TimeRecording>>> perMonthPerEmployee = {};
    for (TimeRecording timeRecording in timeRecordings) {
      String employeePath = timeRecording.employeeRef.path;
      DateTime monthKey =
          DateTime(timeRecording.from.year, timeRecording.from.month);
      Map<String, List<TimeRecording>> monthlySummaryPerEmployee =
          perMonthPerEmployee.putIfAbsent(monthKey, () => {});

      List<TimeRecording> employeeTimeRecordings =
          monthlySummaryPerEmployee.putIfAbsent(employeePath, () => []);
      employeeTimeRecordings.add(timeRecording);
    }
    monthlySummaries = [];
    int currentMonth = DateTime.now().month;
    for (MapEntry<DateTime, Map<String, List<TimeRecording>>> monthEntry
        in perMonthPerEmployee.entries) {
      DateTime dateKey = monthEntry.key;
      MonthlySummary monthlySummary = MonthlySummary(
          dateKey, monthYearFormatter.format(dateKey),
          expanded: currentMonth == dateKey.month);
      for (MapEntry<String, List<TimeRecording>> employeeEntry
          in monthEntry.value.entries) {
        Employee? employee = employeePerPath[employeeEntry.key];
        if (employee != null) {
          MonthlySummaryPerEmployee perEmployee =
              MonthlySummaryPerEmployee(employee);
          for (TimeRecording timeRecording in employeeEntry.value) {
            Wage? wageForTimeRecording;
            List<Wage>? employeeWages =
                wagesPerEmployeePath[employee.employeeRef!.path];
            if (employeeWages != null) {
              for (Wage wage in employeeWages) {
                if (wage.validFrom.isBefore(timeRecording.from) &&
                    (wage.validTo == null ||
                        wage.validTo!.isAfter(timeRecording.from))) {
                  wageForTimeRecording = wage;
                }
              }
            }
            perEmployee.addTimeRecording(
                TimeRecordingWithWage(timeRecording, wageForTimeRecording));
          }
          monthlySummary.employees.add(perEmployee);
        }
      }
      monthlySummary.employees
          .sort((m1, m2) => m1.employee.compareTo(m2.employee));
      monthlySummaries.add(monthlySummary);
    }

    monthlySummaries.sort((m1, m2) => m2.month.compareTo(m1.month));
    for (var monthlySummary in monthlySummaries) {
      for (var employee in monthlySummary.employees) {
        employee.timeRecordings.sort((tr1, tr2) =>
            tr2.timeRecording.from.compareTo(tr1.timeRecording.from));
      }
    }

    emit(TimeRecordingListEmployeeInitialized(monthlySummaries));
  }

  Future<Map<String, List<Wage>>> _readWages() async {
    final queryWages = await sbmContext.queryBuilder
        .wagesForCompany(sbmContext.companyRef!)
        .get();

    List<Wage> wages =
        queryWages.docs.map((e) => Wage.fromSnapshot(e)).toList();

    Map<String, List<Wage>> wagesPerEmployeePath = {};

    for (Wage wage in wages) {
      DocumentReference<DynamicMap> employeeRef = wage.wageRef!.parent.parent!;
      wagesPerEmployeePath.putIfAbsent(employeeRef.path, () => []).add(wage);
    }
    for (List<Wage> employeeWages in wagesPerEmployeePath.values) {
      employeeWages.sort((w1, w2) => w1.validFrom.compareTo(w2.validFrom));
    }
    return wagesPerEmployeePath;
  }

  Future<List<Employee>> _readEmployees() async {
    final queryEmployees = await sbmContext.queryBuilder
        .employeesCollection(sbmContext.companyRef!)
        .get();

    List<Employee> employees =
        queryEmployees.docs.map((e) => Employee.fromSnapshot(e)).toList();
    return employees;
  }

  void setExpanded(int panelIndex, bool isExpanded) {
    monthlySummaries[panelIndex].expanded = !isExpanded;
    emit(TimeRecordingListEmployeeInitialized(monthlySummaries));
  }
}
