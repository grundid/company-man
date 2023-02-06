import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_builder_validators/localization/l10n.dart';
import 'package:intl/intl.dart';
import 'package:routemaster/routemaster.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/main.dart';
import 'package:smallbusiness/reusable/formatters.dart';
import 'package:smallbusiness/reusable/loader.dart';
import 'package:smallbusiness/reusable/model_utils.dart';
import 'package:smallbusiness/reusable/responsive_body.dart';
import 'package:smallbusiness/time_recording/models.dart';
import 'package:smallbusiness/time_recording/time_recording_list_cubit.dart';
import 'package:smallbusiness/time_recording/time_recording_list_employee_cubit.dart';
import 'package:smallbusiness/time_recording/time_recording_widget.dart';
import 'package:smallbusiness/time_recording/utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final DateFormat _dateFormat = DateFormat.yMEd();
final DateFormat _toDateFormat = DateFormat.Hm();

class TimeRecordingListWidget extends StatelessWidget {
  final SbmContext sbmContext;

  TimeRecordingListWidget({Key? key, required this.sbmContext})
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
    return BlocProvider(
      create: (context) => TimeRecordingListCubit(sbmContext),
      child: BlocBuilder<TimeRecordingListCubit, TimeRecordingListState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.arbeitszeitverlauf),
            ),
            floatingActionButton: FloatingActionButton.extended(
                onPressed: () {
                  _editTimeRecording(context);
                },
                icon: Icon(Icons.more_time),
                label: Text(AppLocalizations.of(context)!.arbeitszeitErfassen)),
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
                                                sbmContext: sbmContext,
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
                        child: Text(AppLocalizations.of(context)!
                            .nochKeineZeitenErfasst),
                      )
                : LoadingAnimationScreen(),
          );
        },
      ),
    );
  }
}

class TimeRecordingEntryWidget extends StatelessWidget {
  final SbmContext sbmContext;
  final TimeRecordingWithWage timeRecordingWithWage;
  final Function()? onEditTimeRecording;

  const TimeRecordingEntryWidget({
    Key? key,
    required this.sbmContext,
    required this.timeRecordingWithWage,
    this.onEditTimeRecording,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TimeRecordingHolder timeRecording = timeRecordingWithWage.timeRecording;
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
      subtitle = AppLocalizations.of(context)!.arbeitszeitPause(
          pausingTime.getFormatted(), workingTime.getFormatted());
      if (compensation != null) {
        subtitle +=
            "\n${AppLocalizations.of(context)!.verguetung(compensation)}";
      }
    }
    return ListTile(
      title: Row(
        children: [
          Expanded(child: Text(dateLabel)),
          Expanded(
              child: Text(
            titleLabel,
            textAlign: TextAlign.end,
          )),
        ],
      ),
      isThreeLine: subtitle != null,
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: !timeRecording.finalized ? Icon(Icons.hourglass_bottom) : null,
      onTap: !timeRecording.finalized || sbmContext.user.isManager
          ? onEditTimeRecording
          : null,
    );
  }
}
