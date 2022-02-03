import 'package:flutter/material.dart';
import 'package:smallbusiness/company/models.dart';
import 'package:smallbusiness/reusable/responsive_body.dart';
import 'package:smallbusiness/time_recording/models.dart';
import 'package:smallbusiness/time_recording/time_recording_list_employee_cubit.dart';
import 'package:smallbusiness/time_recording/time_recording_list_widget.dart';
import 'package:smallbusiness/time_recording/utils.dart';

class EmployeeTimeRecodingsWidget extends StatelessWidget {
  final Employee employee;
  final DateTime monthYear;
  final List<TimeRecordingWithWage> timeRecordings;

  const EmployeeTimeRecodingsWidget(
      {Key? key,
      required this.employee,
      required this.monthYear,
      required this.timeRecordings})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "${employee.displayName()} - ${monthYearFormatter.format(monthYear)}"),
      ),
      body: ResponsiveListViewElement(
        child: ListView.builder(
          itemCount: timeRecordings.length,
          itemBuilder: (context, index) => TimeRecordingEntryWidget(
            timeRecordingWithWage: timeRecordings[index],
          ),
        ),
      ),
    );
  }
}
