import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/company/bloc/company_edit_bloc.dart';
import 'package:smallbusiness/reusable/form_editor/form_editor_widget.dart';
import 'package:smallbusiness/reusable/user_actions/models.dart';
import 'package:provider/provider.dart';

class CompanyEditWidget extends StatelessWidget {
  final String? companyId;
  const CompanyEditWidget({Key? key, required this.companyId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    SbmContext sbmContext = context.watch<SbmContext>();
    DocumentReference<DynamicMap>? editingRef = companyId != null
        ? sbmContext.queryBuilder.companyRef(companyId!)
        : null;
    return FormEditorWidget(
      editorTitle: "Firma bearbeiten",
      cubitCreator: (context) => CompanyEditBloc(sbmContext, editingRef),
      formFieldsBuilder: (context, values, formKey, state, execDefaultAction) =>
          [
        FormBuilderTextField(
          autofocus: true,
          valueTransformer: valueTrimmer,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          onSubmitted: execDefaultAction != null
              ? (value) {
                  execDefaultAction();
                }
              : null,
          name: "companyLabel",
          decoration: InputDecoration(label: Text("Firmenname")),
        )
      ],
    );
  }
}
