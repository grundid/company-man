import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/time_recording/time_recording_list_cubit.dart';

class TimeRecordingListWidget extends StatelessWidget {
  final SbmContext sbmContext;

  const TimeRecordingListWidget({Key? key, required this.sbmContext})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Arbeitszeitverlauf"),
      ),
      body: BlocProvider(
        create: (context) => TimeRecordingListCubit(sbmContext),
        child: Container(),
      ),
    );
  }
}
