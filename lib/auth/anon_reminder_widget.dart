import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:routemaster/routemaster.dart';
import 'package:smallbusiness/auth/anon_reminder_cubit.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/main.dart';

class AnonReminderWidget extends StatelessWidget {
  final SbmContext sbmContext;

  const AnonReminderWidget({Key? key, required this.sbmContext})
      : super(key: key);

  Future<String?> askForPhoneNumber(BuildContext context) {
    GlobalKey<FormBuilderState> formKey = GlobalKey();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Telefonnummer"),
        content: FormBuilder(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FormBuilderTextField(
                  name: "phoneNumber",
                  autofocus: true,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(context),
                  ]),
                ),
                ButtonBar(
                  alignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Abbrechen")),
                    ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.saveAndValidate()) {
                            String phoneNumber =
                                formKey.currentState!.value["phoneNumber"];
                            Navigator.pop(context, phoneNumber);
                          }
                        },
                        child: Text("Verifizieren"))
                  ],
                )
              ],
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AnonReminderCubit(sbmContext),
      child: BlocBuilder<AnonReminderCubit, AnonReminderState>(
        builder: (context, state) {
          return state is AnonReminderInitialized && state.showWarning
              ? Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.warning,
                          color: Colors.amber.shade800,
                        ),
                        title: Text(
                          "Warnung",
                          style: TextStyle(color: Colors.amber.shade800),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                            "Sie verwenden im Moment einen anonymen Account. "
                            "Falls Sie die App neuinstallieren oder das Gerät wechseln verlieren Sie all Ihre Daten. "
                            "Ohne einen Account können Sie die App nicht von mehreren Geräten aus nutzen.\n\n"
                            "Wir empfehlen Ihnen für einen langfristigen Einsatz der App Ihren Account mit einer Telefonnummer zu verknüpfen."),
                      ),
                      ButtonBar(
                        alignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                              onPressed: () {
                                context
                                    .read<AnonReminderCubit>()
                                    .remindMeLater();
                              },
                              child: Text("Später")),
                          TextButton(
                              onPressed: () async {
                                String? phoneNumber =
                                    await askForPhoneNumber(context);
                                if (phoneNumber != null) {
                                  Routemaster.of(context).push(RouteNames
                                          .signInWithPhoneNumber +
                                      "?phoneNumber=${Uri.encodeComponent(phoneNumber)}");
                                }
                              },
                              child: Text("Mit Telefonnummer verknüpfen"))
                        ],
                      )
                    ],
                  ),
                )
              : Container();
        },
      ),
    );
  }
}
