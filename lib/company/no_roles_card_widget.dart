import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class NoRolesCardWidget extends StatelessWidget {
  final GlobalKey<FormBuilderState> formKey = GlobalKey();

  final Function() onCreateCompany;
  final Function(String inviteId) onJoinCompany;

  NoRolesCardWidget(
      {Key? key, required this.onCreateCompany, required this.onJoinCompany})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                "Sie können jetzt als Manager eine Firma erstellen oder als Mitarbeiter einer Firma beitreten."),
            ButtonBar(
              children: [
                ElevatedButton(
                    onPressed: onCreateCompany, child: Text("Firma erstellen"))
              ],
            ),
            FormBuilder(
                key: formKey,
                child: Column(
                  children: [
                    Text(
                        "Um einer Firma beizuteten benötigen Sie eine Einladungs-ID, die Sie von Ihrem Manager erhalten."),
                    FormBuilderTextField(
                      name: "inviteId",
                      decoration: InputDecoration(label: Text("Einladungs-ID")),
                      valueTransformer: (value) => value?.trim(),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(context),
                        FormBuilderValidators.minLength(context, 10)
                      ]),
                    ),
                    ButtonBar(
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              if (formKey.currentState!.saveAndValidate()) {
                                onJoinCompany(
                                    formKey.currentState!.value["invoiceId"]);
                              }
                            },
                            child: Text("Firma beitreten"))
                      ],
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
