import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/company/models.dart';
import 'package:smallbusiness/reusable/responsive_body.dart';
import 'package:smallbusiness/time_recording/time_recording_list_employee_cubit.dart';
import 'package:smallbusiness/time_recording/time_recording_list_widget.dart';
import 'package:smallbusiness/time_recording/time_recording_widget.dart';
import 'package:smallbusiness/time_recording/utils.dart';

class EmployeeTimeRecodingsWidget extends StatelessWidget {
  final SbmContext sbmContext;
  final Employee employee;
  final DateTime monthYear;
  final List<TimeRecordingWithWage> timeRecordings;

  const EmployeeTimeRecodingsWidget(
      {Key? key,
      required this.sbmContext,
      required this.employee,
      required this.monthYear,
      required this.timeRecordings})
      : super(key: key);

  _editTimeRecording(BuildContext context, {String? timeRecordingId}) async {
    bool? result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => TimeRecordingWidget(
          sbmContext: sbmContext,
          timeRecordingId: timeRecordingId,
        ),
      ),
    );

    log("result: $result");
    if (true == result) {
      //context.read<TimeRecordingListCubit>().update();
    }
  }

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
              sbmContext: sbmContext,
              timeRecordingWithWage: timeRecordings[index],
              onEditTimeRecording: () {
                _editTimeRecording(context,
                    timeRecordingId:
                        timeRecordings[index].timeRecording.timeRecordingId);
              }),
        ),
      ),
    );
  }
}
