import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:smallbusiness/auth/anon_reminder_widget.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/main.dart';
import 'package:smallbusiness/time_recording/time_recording_widget.dart';

class CompanyMainWidget extends StatelessWidget {
  final SbmContext sbmContext;

  const CompanyMainWidget({Key? key, required this.sbmContext})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      if (sbmContext.user.isManager)
        Card(
          child: ListTile(
            title: Text("Mitarbeiterverwaltung"),
            subtitle: Text("Erfassen und Verwalten Sie hier Ihre Mitarbeiter"),
            onTap: () {
              Routemaster.of(context).push(RouteNames.employeeList);
            },
          ),
        ),
      if (sbmContext.user.isEmployee)
        Card(
          child: InkWell(
            onTap: () {
              _openTimeRecording(context);
            },
            child: Column(
              children: [
                ListTile(
                  title: Text("Arbeitszeiterfassung"),
                  subtitle: Text("Erfassen Sie Ihre Arbeitszeit"),
                ),
                ButtonBar(
                  alignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            Routemaster.of(context)
                                .push(RouteNames.timeRecordingList);
                          },
                          child: Text("Historie"),
                        ),
                        if (sbmContext.user.isManager)
                          TextButton(
                              onPressed: () {
                                Routemaster.of(context)
                                    .push(RouteNames.timeRecordingListEmployee);
                              },
                              child: Text("Mitarbeiter-Auswertungen")),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        _openTimeRecording(context);
                      },
                      child: Text("Erfassen"),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      AnonReminderWidget(sbmContext: sbmContext)
    ]);
  }

  void _openTimeRecording(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => TimeRecordingWidget(
        sbmContext: sbmContext,
      ),
    ));
  }
}
