import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:smallbusiness/auth/app_context.dart';

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
              Routemaster.of(context).push("/employeeList");
            },
          ),
        ),
      if (sbmContext.user.isEmployee)
        Card(
          child: ListTile(
            title: Text("Arbeitszeiterfassung"),
            subtitle: Text("Erfassen Sie Ihre Arbeitszeit"),
            onTap: () {},
          ),
        )
    ]);
  }
}
