import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:smallbusiness/reusable/responsive_body.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SignInWidget extends StatelessWidget {
  final Function onSignIn;
  final Function(String phoneNumber) onSignInWithPhoneNumber;

  const SignInWidget(
      {Key? key, required this.onSignIn, required this.onSignInWithPhoneNumber})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBody(
      addPadding: false,
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

  PhoneQueryWidget({
    Key? key,
    required this.onSignInWithPhoneNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: PhoneQueryFormWidget(
          onSignInWithPhoneNumber: onSignInWithPhoneNumber,
          buttonLabel: "Einloggen",
          title: "Account wiederherstellen",
          introduction: "Falls Sie bereits über einen Account verfügen, "
              "dann geben Sie bitte Ihre Telefonnummer ein um Ihren Account wiederherzustellen.",
        ),
      ),
    );
  }
}

class PhoneQueryFormWidget extends StatelessWidget {
  final GlobalKey<FormBuilderState> formKey = GlobalKey();
  final Function(String phoneNumber) onSignInWithPhoneNumber;
  final String buttonLabel;
  final Function()? onCancel;
  final String introduction;
  final String? title;

  PhoneQueryFormWidget(
      {Key? key,
      required this.onSignInWithPhoneNumber,
      required this.buttonLabel,
      required this.introduction,
      this.onCancel,
      this.title})
      : super(key: key);

  _submitForm() {
    if (formKey.currentState!.saveAndValidate()) {
      onSignInWithPhoneNumber(formKey.currentState!.value["phoneNumber"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) Text("$title\n"),
          Text(introduction),
          FormBuilderTextField(
            name: "phoneNumber",
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            onSubmitted: (value) {
              _submitForm();
            },
            valueTransformer: (value) {
              if (value != null) {
                return value.replaceAll(" ", "");
              }
            },
            initialValue: "+49",
            decoration: InputDecoration(
                errorMaxLines: 2,
                helperMaxLines: 2,
                helperText: "Bitte verwenden Sie das Format +49 123 1234567."),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(context),
              FormBuilderValidators.minLength(context, 10),
              (value) {
                if (value != null && !value.startsWith("+")) {
                  return "Bitte die internationale Vorwahl, z.B. +49 123 1234567 verwenden.";
                }
              }
            ]),
          ),
          ButtonBar(
            alignment: onCancel != null
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.end,
            children: [
              if (onCancel != null)
                TextButton(
                    onPressed: onCancel,
                    child: Text(Localizations.of<MaterialLocalizations>(
                            context, MaterialLocalizations)!
                        .cancelButtonLabel)),
              ElevatedButton(onPressed: _submitForm, child: Text(buttonLabel))
            ],
          )
        ],
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
              Text("Willkommen bei der Small Business App"),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                    "Mit dieser App können Sie Ihr Unternehmen und Ihre Mitarbeiter verwalten."),
              ),
              Text(
                  "Um Fortzufahren akzeptieren Sie bitte die Datenschutzbestimmungen und die AGBs. "
                  "Im Anschluss wird für Sie ein anonymer Account erstellt und Sie können die App unverbindlich ausprobieren."),
              Row(
                children: [
                  Expanded(
                    child: FormBuilderCheckbox(
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
                  ),
                  IconButton(
                      onPressed: () async {
                        if (await canLaunch("https://grundid.de/privacy")) {
                          launch("https://grundid.de/privacy");
                        }
                      },
                      icon: Icon(Icons.link))
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: FormBuilderCheckbox(
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
                  ),
                  IconButton(
                      onPressed: () async {
                        if (await canLaunch(
                            "https://grundid.de/agb-smallbusiness-beta.html")) {
                          launch(
                              "https://grundid.de/agb-smallbusiness-beta.html");
                        }
                      },
                      icon: Icon(Icons.link))
                ],
              ),
              ButtonBar(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.saveAndValidate()) {
                          onSignIn();
                        }
                      },
                      child: Text(
                        AppLocalizations.of(context)!.akzeptieren,
                      ))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
