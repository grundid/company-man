import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:routemaster/routemaster.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/main.dart';
import 'package:smallbusiness/reusable/formatters.dart';
import 'package:smallbusiness/reusable/loader.dart';
import 'package:smallbusiness/reusable/responsive_body.dart';
import 'package:smallbusiness/time_recording/models.dart';
import 'package:smallbusiness/time_recording/time_recording_list_cubit.dart';
import 'package:smallbusiness/time_recording/time_recording_list_employee_cubit.dart';
import 'package:smallbusiness/time_recording/utils.dart';

final DateFormat _dateFormat = DateFormat.yMEd();
final DateFormat _toDateFormat = DateFormat.Hm();

class TimeRecordingListWidget extends StatelessWidget {
  final SbmContext sbmContext;

  TimeRecordingListWidget({Key? key, required this.sbmContext})
      : super(key: key);

  _editTimeRecording(BuildContext context, {String? timeRecordingId}) async {
    bool? result = await Routemaster.of(context)
        .push<bool>(RouteNames.timeRecordingListEdit +
            (timeRecordingId != null
                ? "?timeRecordingId=$timeRecordingId"
                : ""))
        .result;
    log("result: $result");
    if (true == result) {
      context.read<TimeRecordingListCubit>().update();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TimeRecordingListCubit(sbmContext),
      child: BlocBuilder<TimeRecordingListCubit, TimeRecordingListState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Arbeitszeitverlauf"),
            ),
            floatingActionButton: FloatingActionButton.extended(
                onPressed: () {
                  _editTimeRecording(context);
                },
                icon: Icon(Icons.more_time),
                label: Text("Arbeitszeit erfassen")),
            body: state is TimeRecordingListInitialized
                ? state.groups.isNotEmpty
                    ? ResponsiveBody(
                        addPadding: false,
                        child: ExpansionPanelList(
                          expansionCallback: (panelIndex, isExpanded) {
                            context
                                .read<TimeRecordingListCubit>()
                                .setExpanded(panelIndex, isExpanded);
                          },
                          children: state.groups
                              .map(
                                (e) => ExpansionPanel(
                                  canTapOnHeader: true,
                                  isExpanded: e.expanded,
                                  headerBuilder: (context, isExpanded) => Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 16),
                                        child: Text(e.label),
                                      ),
                                      Text(e.totalDuration.toString())
                                    ],
                                  ),
                                  body: Column(
                                    children: e.timeRecordings
                                        .map((timeRecoding) =>
                                            TimeRecordingEntryWidget(
                                                timeRecordingWithWage:
                                                    TimeRecordingWithWage(
                                                        timeRecoding, null),
                                                onEditTimeRecording: () {
                                                  _editTimeRecording(context,
                                                      timeRecordingId:
                                                          timeRecoding
                                                              .timeRecordingRef!
                                                              .id);
                                                }))
                                        .toList(),
                                  ),
                                ),
                              )
                              .toList(),
                        ))
                    : Center(
                        child: Text("Noch keine Zeiten erfasst"),
                      )
                : LoadingAnimationScreen(),
          );
        },
      ),
    );
  }
}

class TimeRecordingEntryWidget extends StatelessWidget {
  final TimeRecordingWithWage timeRecordingWithWage;
  final Function()? onEditTimeRecording;

  const TimeRecordingEntryWidget(
      {Key? key, required this.timeRecordingWithWage, this.onEditTimeRecording})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    TimeRecording timeRecording = timeRecordingWithWage.timeRecording;
    String dateLabel = _dateFormat.format(timeRecording.from);
    String fromLabel = _toDateFormat.format(timeRecording.from);
    String? toLabel = timeRecording.to != null
        ? _toDateFormat.format(timeRecording.to!)
        : null;
    String titleLabel = fromLabel + (toLabel != null ? (" - $toLabel") : "");
    Duration? duration = timeRecording.duration;
    String? compensation;
    if (duration != null && timeRecordingWithWage.wage != null) {
      compensation = centToUserOutput(calculateWage(
          HoursMinutes.fromDuration(duration), timeRecordingWithWage.wage!));
    }
    Duration pauseDuration = timeRecording.pauseDuration;
    String? subtitle;
    if (duration != null) {
      TimeOfDay workingTime = fromDuration(duration);
      TimeOfDay pausingTime = fromDuration(pauseDuration);
      subtitle =
          "Arbeitszeit: ${workingTime.getFormatted()}, Pausezeit: ${pausingTime.getFormatted()}";
      if (compensation != null) {
        subtitle += ", Vergütung $compensation";
      }
    }
    return ListTile(
      title: Row(
        children: [
          Expanded(child: Text(dateLabel)),
          Expanded(child: Text(titleLabel)),
        ],
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: !timeRecording.finalized && onEditTimeRecording != null
          ? IconButton(onPressed: onEditTimeRecording, icon: Icon(Icons.edit))
          : null,
    );
  }
}
