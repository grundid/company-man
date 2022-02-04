import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/company/bloc/employee_edit_bloc.dart';
import 'package:smallbusiness/reusable/form_editor/form_editor_widget.dart';
import 'package:smallbusiness/reusable/user_actions/models.dart';
import 'package:provider/provider.dart';

class EmployeeEditWidget extends StatelessWidget {
  final String? employeeId;

  const EmployeeEditWidget({Key? key, this.employeeId}) : super(key: key);

  _defaultActionHandler(Function() execDefaultAction) {
    return (value) => execDefaultAction();
  }

  @override
  Widget build(BuildContext context) {
    SbmContext sbmContext = Provider.of<SbmContext>(context, listen: false);
    DocumentReference<DynamicMap>? employeeRef = employeeId != null
        ? sbmContext.queryBuilder
            .employeeRef(sbmContext.companyRef!, employeeId!)
        : null;
    return FormEditorWidget(
      editorTitle: "Mitarbeiter bearbeiten",
      cubitCreator: (context) => EmployeeEditBloc(sbmContext, employeeRef),
      formFieldsBuilder: (context, values, formKey, state, execDefaultAction) =>
          [
        FormBuilderDropdown(
          name: "gender",
          items: [
            DropdownMenuItem(value: "female", child: Text("Frau")),
            DropdownMenuItem(value: "male", child: Text("Herr")),
          ],
          decoration: InputDecoration(label: Text("Anrede")),
          validator: FormBuilderValidators.compose(
              [FormBuilderValidators.required(context)]),
        ),
        FormBuilderTextField(
          autofocus: true,
          name: "firstName",
          textCapitalization: TextCapitalization.words,
          valueTransformer: valueTrimmer,
          onSubmitted: execDefaultAction != null
              ? _defaultActionHandler(execDefaultAction)
              : null,
          decoration: InputDecoration(label: Text("Vorname")),
          validator: FormBuilderValidators.compose(
              [FormBuilderValidators.required(context)]),
        ),
        FormBuilderTextField(
          name: "lastName",
          textCapitalization: TextCapitalization.words,
          valueTransformer: valueTrimmer,
          onSubmitted: execDefaultAction != null
              ? _defaultActionHandler(execDefaultAction)
              : null,
          decoration: InputDecoration(label: Text("Nachname")),
          validator: FormBuilderValidators.compose(
              [FormBuilderValidators.required(context)]),
        ),
        FormBuilderTextField(
          name: "employeeNo",
          valueTransformer: valueTrimmer,
          onSubmitted: execDefaultAction != null
              ? _defaultActionHandler(execDefaultAction)
              : null,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(label: Text("Mitarbeiternummer")),
          validator: FormBuilderValidators.compose(
            [
              FormBuilderValidators.required(context),
              FormBuilderValidators.integer(context)
            ],
          ),
        ),
        Row(
          children: [
            Flexible(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FormBuilderTextField(
                  name: "street",
                  textCapitalization: TextCapitalization.words,
                  valueTransformer: valueTrimmer,
                  onSubmitted: execDefaultAction != null
                      ? _defaultActionHandler(execDefaultAction)
                      : null,
                  decoration: InputDecoration(label: Text("Straße")),
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: FormBuilderTextField(
                name: "no",
                valueTransformer: valueTrimmer,
                onSubmitted: execDefaultAction != null
                    ? _defaultActionHandler(execDefaultAction)
                    : null,
                decoration: InputDecoration(label: Text("Nummer")),
              ),
            )
          ],
        ),
        FormBuilderTextField(
          name: "additional",
          textCapitalization: TextCapitalization.words,
          valueTransformer: valueTrimmer,
          onSubmitted: execDefaultAction != null
              ? _defaultActionHandler(execDefaultAction)
              : null,
          decoration: InputDecoration(label: Text("Addresszusatz")),
        ),
        Row(
          children: [
            Flexible(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FormBuilderTextField(
                  name: "postalCode",
                  keyboardType: TextInputType.number,
                  valueTransformer: valueTrimmer,
                  decoration: InputDecoration(label: Text("PLZ")),
                ),
              ),
            ),
            Flexible(
              flex: 4,
              child: FormBuilderTextField(
                name: "city",
                textCapitalization: TextCapitalization.words,
                valueTransformer: valueTrimmer,
                onSubmitted: execDefaultAction != null
                    ? _defaultActionHandler(execDefaultAction)
                    : null,
                decoration: InputDecoration(label: Text("Stadt")),
              ),
            )
          ],
        ),
        FormBuilderTextField(
          name: "email",
          valueTransformer: valueTrimmer,
          onSubmitted: execDefaultAction != null
              ? _defaultActionHandler(execDefaultAction)
              : null,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(label: Text("E-Mail")),
        ),
        FormBuilderTextField(
          name: "phone",
          valueTransformer: valueTrimmer,
          onSubmitted: execDefaultAction != null
              ? _defaultActionHandler(execDefaultAction)
              : null,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(label: Text("Telefon")),
        ),
      ],
    );
  }
}
