import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class SignInWidget extends StatelessWidget {
  final Function onSignIn;
  final Function(String phoneNumber) onSignInWithPhoneNumber;

  const SignInWidget(
      {Key? key, required this.onSignIn, required this.onSignInWithPhoneNumber})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _AnonSignInWidget(onSignIn: onSignIn),
          PhoneQueryWidget(
            onSignInWithPhoneNumber: onSignInWithPhoneNumber,
          )
        ],
      ),
    );
  }
}

class PhoneQueryWidget extends StatelessWidget {
  final Function(String phoneNumber) onSignInWithPhoneNumber;
  final GlobalKey<FormBuilderState> formKey = GlobalKey();

  PhoneQueryWidget({
    Key? key,
    required this.onSignInWithPhoneNumber,
  }) : super(key: key);

  _submitForm() {
    if (formKey.currentState!.saveAndValidate()) {
      onSignInWithPhoneNumber(formKey.currentState!.value["phoneNumber"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: formKey,
          child: Column(
            children: [
              Text("Account wiederherstellen\n"),
              Text("Falls Sie bereits über einen Account verfügen, "
                  "dann geben Sie bitte Ihre Telefonnummer ein um Ihren Account wiederherzustellen."),
              FormBuilderTextField(
                name: "phoneNumber",
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                onSubmitted: (value) {
                  _submitForm();
                },
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(context),
                ]),
              ),
              ButtonBar(
                children: [
                  ElevatedButton(
                      onPressed: _submitForm, child: Text("Einloggen"))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _AnonSignInWidget extends StatelessWidget {
  final GlobalKey<FormBuilderState> formKey = GlobalKey();
  final Function onSignIn;

  _AnonSignInWidget({
    Key? key,
    required this.onSignIn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
                      child: Text("Akzeptieren"))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
