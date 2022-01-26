import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:routemaster/routemaster.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/auth/phone_signin_cubit.dart';
import 'package:smallbusiness/reusable/loader.dart';
import 'package:smallbusiness/reusable/responsive_body.dart';

class PhoneSignInWidget extends StatelessWidget {
  final SbmContext sbmContext;
  final String phoneNumber;
  const PhoneSignInWidget(
      {Key? key, required this.phoneNumber, required this.sbmContext})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PhoneSigninCubit(sbmContext, phoneNumber),
      child: Scaffold(
        appBar: AppBar(
          title: Text("$phoneNumber verifizieren"),
        ),
        body: BlocBuilder<PhoneSigninCubit, PhoneSigninState>(
          builder: (context, state) {
            return ResponsiveBody(
                addPadding: false,
                child: state is PhoneSigninCodeSent
                    ? VerificationCodeWidget(
                        phoneNumber: phoneNumber,
                        onCodeResend: () {},
                        onCodeSubmit: (code) {
                          context
                              .read<PhoneSigninCubit>()
                              .verifyCode(state.verificationId, code);
                        },
                      )
                    : state is PhoneSigninVerified
                        ? Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                    "Die Nummer wurde erfolgreich geprüft und Ihr Account verknüpft. "
                                    "Sie können sich jetzt und in Zukunft direkt mit Ihrer Telefonnummer einloggen um auf Ihre Daten zugreifen zu können."),
                                ButtonBar(
                                  alignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                        onPressed: () {
                                          Routemaster.of(context).pop();
                                        },
                                        child: Text("Fertig"))
                                  ],
                                )
                              ],
                            ),
                          )
                        : state is PhoneSigninError
                            ? Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Fehler bei der Verifizierung:"),
                                    Text(state.message)
                                  ],
                                ),
                              )
                            : LoadingAnimationScreen());
          },
        ),
      ),
    );
  }
}

class VerificationCodeWidget extends StatelessWidget {
  final String phoneNumber;
  final Function(String code) onCodeSubmit;
  final Function() onCodeResend;
  final GlobalKey<FormBuilderState> formKey = GlobalKey();

  VerificationCodeWidget({
    Key? key,
    required this.phoneNumber,
    required this.onCodeSubmit,
    required this.onCodeResend,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
                "An die Telefonnummer $phoneNumber wurde ein Bestätigungscode geschickt. "
                "Bitte diesen Code in das folgende Feld eingeben:"),
            FormBuilderTextField(
              name: "code",
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(label: Text("Bestätigungscode")),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(context),
                FormBuilderValidators.maxLength(context, 6),
                FormBuilderValidators.minLength(context, 6),
              ]),
            ),
            ButtonBar(
              alignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                    onPressed: onCodeResend, child: Text("Erneut senden")),
                ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.saveAndValidate()) {
                        onCodeSubmit(formKey.currentState!.value["code"]);
                      }
                    },
                    child: Text("Prüfen"))
              ],
            )
          ],
        ),
      ),
    );
  }
}
