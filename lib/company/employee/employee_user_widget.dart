import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/company/employee/employee_user_cubit.dart';
import 'package:provider/provider.dart';
import 'package:smallbusiness/reusable/loader.dart';
import 'package:smallbusiness/reusable/responsive_body.dart';
import 'package:smallbusiness/reusable/user_actions/models.dart';

class EmployeeUserWidget extends StatelessWidget {
  final String employeeId;

  const EmployeeUserWidget({Key? key, required this.employeeId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Berechtigungen"),
      ),
      body: BlocProvider(
        create: (context) => EmployeeUserCubit(
            Provider.of<SbmContext>(context, listen: false), employeeId),
        child: BlocBuilder<EmployeeUserCubit, EmployeeUserState>(
          builder: (context, state) {
            return state is EmployeeUserNoUser
                ? _NoUserWidget(
                    onInvite: (DynamicMap values) {
                      context.read<EmployeeUserCubit>().createInvite(values);
                    },
                  )
                : state is EmployeeUserInvitationAvailable
                    ? _InvitationAvailableWidget(
                        inviteId: state.inviteId,
                      )
                    : state is EmployeeUserInitialized
                        ? _UserInitializedWidget(
                            formValues: state.formValues,
                            onChangeRights: (values) {
                              context
                                  .read<EmployeeUserCubit>()
                                  .changeRights(state.objectRoleRef, values);
                            },
                          )
                        : LoadingAnimationScreen();
          },
        ),
      ),
    );
  }
}

class _UserInitializedWidget extends StatelessWidget {
  final GlobalKey<FormBuilderState> formKey = GlobalKey();
  final DynamicMap formValues;
  final Function(DynamicMap values) onChangeRights;

  _UserInitializedWidget({
    Key? key,
    required this.formValues,
    required this.onChangeRights,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBody(
        child: FormBuilder(
      key: formKey,
      initialValue: formValues,
      child: Column(
        children: [
          FormBuilderCheckbox(
            name: "employee",
            title: Text("Mitarbeiter-Berechtigung"),
            decoration: InputDecoration(
                helperMaxLines: 3,
                helperText:
                    "Die Mitarbeiter-Berechtigung erlaubt es dem Benutzer Arbeitszeiten zu erfassen und weitere von Ihnen festgelegte Aufgaben auszuführen."),
          ),
          FormBuilderCheckbox(
            name: "manager",
            title: Text("Manager-Berechtigung"),
            decoration: InputDecoration(
                helperMaxLines: 3,
                helperText:
                    "Die Manager-Berechtigung erlaubt es dem Benutzer die komplette Firma und die Mitarbeiter zu verwalten."),
          ),
          ButtonBar(
            children: [
              ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.saveAndValidate()) {
                      onChangeRights(formKey.currentState!.value);
                    }
                  },
                  child: Text("Berechtigung ändern"))
            ],
          )
        ],
      ),
    ));
  }
}

class _InvitationAvailableWidget extends StatelessWidget {
  final String inviteId;
  const _InvitationAvailableWidget({
    Key? key,
    required this.inviteId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBody(
        child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
              "Für den Benutzer ist bereits eine Einladungs-ID erstellt. "
              "Bitte schicken Sie die Einladungs-ID an den Mitarbeiter per Mail, SMS oder WhatsApp."),
        ),
        Column(
          children: [
            Text(
              "Einladungs-ID: $inviteId",
              style: Theme.of(context).textTheme.headline6,
            ),
            ElevatedButton.icon(
              label: Text("Kopieren"),
              icon: Icon(Icons.copy),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: inviteId));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("In die Zwischenablage kopiert."),
                  ),
                );
              },
            )
          ],
        ),
      ],
    ));
  }
}

class _NoUserWidget extends StatelessWidget {
  final Function(DynamicMap values) onInvite;

  const _NoUserWidget({
    Key? key,
    required this.onInvite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    GlobalKey<FormBuilderState> formKey = GlobalKey();
    return ResponsiveBody(
      child: FormBuilder(
        key: formKey,
        child: Column(
          children: [
            Text("Bitte legen Sie für den Mitarbeiter die Berechtigungen "
                "fest und erstellen Sie eine Einladung."),
            FormBuilderCheckbox(
              name: "employee",
              initialValue: true,
              title: Text("Mitarbeiter-Berechtigung"),
              decoration: InputDecoration(
                  helperMaxLines: 3,
                  helperText:
                      "Die Mitarbeiter-Berechtigung erlaubt es dem Benutzer Arbeitszeiten zu erfassen und weitere von Ihnen festgelegte Aufgaben auszuführen."),
            ),
            FormBuilderCheckbox(
              name: "manager",
              initialValue: false,
              title: Text("Manager-Berechtigung"),
              decoration: InputDecoration(
                  helperMaxLines: 3,
                  helperText:
                      "Die Manager-Berechtigung erlaubt es dem Benutzer die komplette Firma und die Mitarbeiter zu verwalten."),
            ),
            ButtonBar(
              children: [
                ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.saveAndValidate()) {
                        onInvite(formKey.currentState!.value);
                      }
                    },
                    child: Text("Einladung erstellen"))
              ],
            )
          ],
        ),
      ),
    );
  }
}
