import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:routemaster/routemaster.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/main.dart';
import 'package:smallbusiness/reusable/loader.dart';
import 'package:smallbusiness/time_recording/models.dart';
import 'package:smallbusiness/time_recording/time_recording_list_cubit.dart';
import 'package:smallbusiness/time_recording/utils.dart';

final DateFormat _fromDateFormat = DateFormat.yMEd().add_Hm();
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
                ? SingleChildScrollView(
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
                                    padding: const EdgeInsets.only(left: 16),
                                    child: Text(e.label),
                                  ),
                                  Text(e.totalDuration.toString())
                                ],
                              ),
                              body: Column(
                                children: e.timeRecordings
                                    .map((timeRecoding) =>
                                        TimeRecordingEntryWidget(
                                            timeRecording: timeRecoding,
                                            onEditTimeRecording: () {
                                              _editTimeRecording(context,
                                                  timeRecordingId: timeRecoding
                                                      .timeRecordingRef!.id);
                                            }))
                                    .toList(),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  )
                : LoadingAnimationScreen(),
          );
        },
      ),
    );
  }
}

class TimeRecordingEntryWidget extends StatelessWidget {
  final TimeRecording timeRecording;
  final Function() onEditTimeRecording;

  const TimeRecordingEntryWidget(
      {Key? key,
      required this.timeRecording,
      required this.onEditTimeRecording})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String fromLabel = _fromDateFormat.format(timeRecording.from);
    String? toLabel = timeRecording.to != null
        ? _toDateFormat.format(timeRecording.to!)
        : null;
    String titleLabel = fromLabel + (toLabel != null ? (" - $toLabel") : "");
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
          ? IconButton(onPressed: onEditTimeRecording, icon: Icon(Icons.edit))
          : null,
    );
  }
}
