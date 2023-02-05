import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/reusable/loader.dart';
import 'package:smallbusiness/reusable/responsive_body.dart';
import 'package:smallbusiness/share/export_utils.dart';
import 'package:smallbusiness/share/share_widget.dart';
import 'package:smallbusiness/time_recording/employee_time_recodings_widget.dart';
import 'package:smallbusiness/time_recording/time_recording_list_employee_cubit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TimeRecordingListEmployeeWidget extends StatelessWidget {
  final SbmContext sbmContext;

  const TimeRecordingListEmployeeWidget({Key? key, required this.sbmContext})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TimeRecordingListEmployeeCubit(sbmContext),
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.arbeitszeiten),
        ),
        body: BlocBuilder<TimeRecordingListEmployeeCubit,
            TimeRecordingListEmployeeState>(
          builder: (context, state) =>
              state is TimeRecordingListEmployeeInitialized
                  ? state.monthlySummaries.isNotEmpty
                      ? ResponsiveBody(
                          addPadding: false,
                          child: ExpansionPanelList(
                            expansionCallback: (panelIndex, isExpanded) {
                              context
                                  .read<TimeRecordingListEmployeeCubit>()
                                  .setExpanded(panelIndex, isExpanded);
                            },
                            children: state.monthlySummaries
                                .map(
                                  (monthlySummary) => ExpansionPanel(
                                    canTapOnHeader: true,
                                    isExpanded: monthlySummary.expanded,
                                    headerBuilder: (context, isExpanded) =>
                                        ListTile(
                                      title: Text(
                                        monthlySummary.label,
                                      ),
                                      trailing: ShareWidget(
                                        shareableBuilder: () async {
                                          return exportMonthlySummary(
                                              monthlySummary);
                                        },
                                      ),
                                    ),
                                    body: Column(
                                      children: monthlySummary.employees
                                          .map(
                                            (perEmployee) => ListTile(
                                              title: Text(perEmployee.employee
                                                  .displayName()),
                                              subtitle: Text(perEmployee
                                                  .hoursMinutes
                                                  .toString()),
                                              onTap: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        EmployeeTimeRecodingsWidget(
                                                      sbmContext: sbmContext,
                                                      employee:
                                                          perEmployee.employee,
                                                      monthYear:
                                                          monthlySummary.month,
                                                      timeRecordings:
                                                          perEmployee
                                                              .timeRecordings,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        )
                      : Center(
                          child: Text(AppLocalizations.of(context)!
                              .keineMitarbeiterAuswertungenVerfuegbar),
                        )
                  : LoadingAnimationScreen(),
        ),
      ),
    );
  }
}
