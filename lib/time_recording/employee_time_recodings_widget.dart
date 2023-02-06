import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/company/models.dart';
import 'package:smallbusiness/reusable/loader.dart';
import 'package:smallbusiness/reusable/responsive_body.dart';
import 'package:smallbusiness/reusable/state.dart';
import 'package:smallbusiness/time_recording/employee_time_recording_cubit.dart';
import 'package:smallbusiness/time_recording/time_recording_list_widget.dart';
import 'package:smallbusiness/time_recording/time_recording_widget.dart';
import 'package:smallbusiness/time_recording/utils.dart';

class EmployeeTimeRecodingsWidget extends StatelessWidget {
  final SbmContext sbmContext;
  final Employee employee;
  final DateTime monthYear;

  const EmployeeTimeRecodingsWidget(
      {Key? key,
      required this.sbmContext,
      required this.employee,
      required this.monthYear})
      : super(key: key);

  _editTimeRecording(BuildContext context, {String? timeRecordingId}) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => TimeRecordingWidget(
          sbmContext: sbmContext,
          timeRecordingId: timeRecordingId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "${employee.displayName()} - ${monthYearFormatter.format(monthYear)}"),
      ),
      body: BlocProvider(
        create: (context) => EmployeeTimeRecodingsCubit(
            sbmContext, employee.employeeRef!, monthYear),
        child: BlocBuilder<EmployeeTimeRecodingsCubit, AppState>(
          builder: (context, state) {
            return state is EmployeeTimeRecodingsInitialized
                ? ResponsiveListViewElement(
                    child: ListView.builder(
                      itemCount: state.timeRecordings.length,
                      itemBuilder: (context, index) => TimeRecordingEntryWidget(
                          sbmContext: sbmContext,
                          timeRecordingWithWage: state.timeRecordings[index],
                          onEditTimeRecording: () {
                            _editTimeRecording(context,
                                timeRecordingId: state.timeRecordings[index]
                                    .timeRecording.timeRecordingId);
                          }),
                    ),
                  )
                : LoadingAnimationScreen(
                    state: state,
                  );
          },
        ),
      ),
    );
  }
}
