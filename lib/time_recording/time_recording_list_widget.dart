import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/reusable/loader.dart';
import 'package:smallbusiness/time_recording/models.dart';
import 'package:smallbusiness/time_recording/time_recording_list_cubit.dart';
import 'package:smallbusiness/time_recording/utils.dart';

class TimeRecordingListWidget extends StatelessWidget {
  final SbmContext sbmContext;
  final DateFormat dateFormat = DateFormat.yMEd().add_Hm();

  TimeRecordingListWidget({Key? key, required this.sbmContext})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Arbeitszeitverlauf"),
      ),
      body: BlocProvider(
        create: (context) => TimeRecordingListCubit(sbmContext),
        child: BlocBuilder<TimeRecordingListCubit, TimeRecordingListState>(
          builder: (context, state) {
            return state is TimeRecordingListInitialized
                ? ListView.builder(
                    itemCount: state.timeRecordings.length,
                    itemBuilder: (context, index) {
                      TimeRecording timeRecording = state.timeRecordings[index];
                      String fromLabel = dateFormat.format(timeRecording.from);
                      String? toLabel = timeRecording.to != null
                          ? dateFormat.format(timeRecording.to!)
                          : null;
                      String titleLabel =
                          fromLabel + (toLabel != null ? (" - $toLabel") : "");
                      Duration? duration = timeRecording.to != null
                          ? timeRecording.to!.difference(timeRecording.from)
                          : null;
                      String? subtitle;
                      if (duration != null) {
                        TimeOfDay timeOfDay = fromDuration(duration);
                        subtitle = "Dauer: ${timeOfDay.getFormatted()}";
                      }
                      return ListTile(
                        title: Text(titleLabel),
                        subtitle: subtitle != null ? Text(subtitle) : null,
                        trailing: toLabel == null
                            ? IconButton(
                                onPressed: () {}, icon: Icon(Icons.edit))
                            : null,
                      );
                    },
                  )
                : LoadingAnimationScreen();
          },
        ),
      ),
    );
  }
}
