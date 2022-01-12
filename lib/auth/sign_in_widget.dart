import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class SignInWidget extends StatelessWidget {
  final Function onSignIn;
  final GlobalKey<FormBuilderState> formKey = GlobalKey();

  SignInWidget({Key? key, required this.onSignIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FormBuilder(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Willkommen beim Small Business Manager"),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                        "Mit dieser App können Sie Ihr Unternehmen und Ihre Mitarbeiter verwalten."),
                  ),
                  Text(
                      "Um Fortzufahren akzeptieren Sie bitte die Datenschutzbestimmungen und die AGBs. "
                      "Im Anschluss wird für Sie ein anonymer Account erstellt und Sie können die App unverbindlich ausprobieren."),
                  FormBuilderCheckbox(
                    name: "privacy",
                    initialValue: false,
                    title: Text("Datenschutzbestimmungen"),
                    decoration: InputDecoration(errorMaxLines: 3),
                    validator: (value) {
                      if (true != value) {
                        return "Bitte bestätigen Sie, dass Sie mit den Datenschutzbestimmungen einverstanden sind.";
                      } else {
                        return null;
                      }
                    },
                  ),
                  FormBuilderCheckbox(
                    name: "terms",
                    initialValue: false,
                    title: Text("AGBs"),
                    decoration: InputDecoration(errorMaxLines: 3),
                    validator: (value) {
                      if (true != value) {
                        return "Bitte bestätigen Sie, dass Sie mit den AGBs einverstanden sind.";
                      } else {
                        return null;
                      }
                    },
                  ),
                  ButtonBar(
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.saveAndValidate()) {
                              onSignIn();
                            }
                          },
                          child: Text("Anzeptieren"))
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
