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
        body: BlocBuilder<PhoneSigninCubit, PhoneSignInState>(
          builder: (context, state) {
            return state is PhoneSignInInProgress
                ? LoadingAnimationScreen(
                    timeout: Duration(seconds: 30),
                  )
                : ResponsiveBody(
                    child: state is PhoneSignInCodeSent
                        ? VerificationCodeWidget(
                            phoneNumber: phoneNumber,
                            onCodeResend: state.forceResendingToken != null
                                ? () {
                                    context
                                        .read<PhoneSigninCubit>()
                                        .resendCode(state.forceResendingToken!);
                                  }
                                : null,
                            onCodeSubmit: (code) {
                              context
                                  .read<PhoneSigninCubit>()
                                  .verifyCode(state.verificationId, code);
                            },
                          )
                        : state is PhoneSignInVerified
                            ? _CodeVerifiedWidget(
                                linked: state.linked,
                              )
                            : state is PhoneSignInInvalidCode
                                ? _InvalidCodeWidget(
                                    forceResendingToken:
                                        state.forceResendingToken,
                                    onResend: (forceResendingToken) {
                                      context
                                          .read<PhoneSigninCubit>()
                                          .resendCode(forceResendingToken);
                                    },
                                  )
                                : state is PhoneSignInAlreadyInUse
                                    ? _AlreadyInUseWidget(
                                        onRelogin: () {
                                          context
                                              .read<PhoneSigninCubit>()
                                              .signOutAndRelogin(
                                                  state.credential);
                                        },
                                      )
                                    : state is PhoneSignInError
                                        ? _VerificationErrorWidget(
                                            message: state.message,
                                          )
                                        : Center(
                                            child: Text("Unknown state"),
                                          ),
                  );
          },
        ),
      ),
    );
  }
}

class _VerificationErrorWidget extends StatelessWidget {
  final String message;
  const _VerificationErrorWidget({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Text("Fehler bei der Verifizierung:"), Text(message)],
    );
  }
}

class _AlreadyInUseWidget extends StatelessWidget {
  final Function() onRelogin;

  const _AlreadyInUseWidget({
    Key? key,
    required this.onRelogin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Die Telefonnummer ist bereits mit einem Account verknüpft. "
            "Sie können sich jetzt abmelden und bei dem existierenden Account anmelden.\n\n"
            "Bitte beachten Sie, dass Sie beim Abmelden Zugriff auf die aktuellen Daten verlieren."),
        ButtonBar(
          alignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: onRelogin, child: Text("Abmelden und Anmelden"))
          ],
        )
      ],
    );
  }
}

class _InvalidCodeWidget extends StatelessWidget {
  final int? forceResendingToken;
  final Function(int forceResendingToken) onResend;

  const _InvalidCodeWidget({
    Key? key,
    this.forceResendingToken,
    required this.onResend,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Der eingegebene Code ist ungültig.\n"),
        if (forceResendingToken != null) ...[
          Text(
              "Bitte lassen Sie sich einen neuen Code zusenden und probieren Sie es erneut."),
          ButtonBar(
            children: [
              TextButton(
                  onPressed: () {
                    onResend(forceResendingToken!);
                  },
                  child: Text("Erneut senden"))
            ],
          )
        ]
      ],
    );
  }
}

class _CodeVerifiedWidget extends StatelessWidget {
  final bool linked;
  const _CodeVerifiedWidget({
    Key? key,
    required this.linked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (linked)
          Text(
              "Die Nummer wurde erfolgreich geprüft und Ihr Account verknüpft. "
              "Sie können sich jetzt und in Zukunft direkt mit Ihrer Telefonnummer "
              "einloggen um auf Ihre Daten zugreifen zu können."),
        if (!linked) Text("Sie haben sich erfolgreich angemeldet."),
        ButtonBar(
          alignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () {
                  Routemaster.of(context).pop();
                },
                child: Text("Weiter"))
          ],
        )
      ],
    );
  }
}

class VerificationCodeWidget extends StatelessWidget {
  final String phoneNumber;
  final Function(String code) onCodeSubmit;
  final Function()? onCodeResend;
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
      child: Column(
        children: [
          Text(
              "An die Telefonnummer $phoneNumber wurde ein Bestätigungscode geschickt. "
              "Bitte diesen Code in das folgende Feld eingeben:"),
          FormBuilderTextField(
            name: "code",
            autofocus: true,
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.number,
            onSubmitted: (value) {
              if (formKey.currentState!.saveAndValidate()) {
                onCodeSubmit(formKey.currentState!.value["code"]);
              }
            },
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
              if (onCodeResend != null)
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
    );
  }
}
