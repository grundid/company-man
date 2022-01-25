import 'package:bloc/bloc.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/company/models.dart';
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

class MonthlySummaryPerEmployee {
  final Employee employee;
  final HoursMinutes hoursMinutes = HoursMinutes.zero();
  final List<TimeRecording> timeRecordings = [];

  MonthlySummaryPerEmployee(this.employee);

  void addTimeRecording(TimeRecording timeRecording) {
    timeRecordings.add(timeRecording);
    Duration? duration = timeRecording.duration();
    if (duration != null) {
      hoursMinutes.add(HoursMinutes.fromDuration(duration));
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
    final queryEmployees = await sbmContext.queryBuilder
        .employeesCollection(sbmContext.companyRef!)
        .get();

    List<Employee> employees =
        queryEmployees.docs.map((e) => Employee.fromSnapshot(e)).toList();

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
          employeeEntry.value.forEach(perEmployee.addTimeRecording);
          monthlySummary.employees.add(perEmployee);
        }
      }
      monthlySummary.employees
          .sort((m1, m2) => sortEmployeeByName(m1.employee, m2.employee));
      monthlySummaries.add(monthlySummary);
    }

    monthlySummaries.sort((m1, m2) => m2.month.compareTo(m1.month));

    emit(TimeRecordingListEmployeeInitialized(monthlySummaries));
  }

  void setExpanded(int panelIndex, bool isExpanded) {
    monthlySummaries[panelIndex].expanded = !isExpanded;
    emit(TimeRecordingListEmployeeInitialized(monthlySummaries));
  }
}
