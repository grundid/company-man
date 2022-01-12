import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/company/models.dart';
import 'package:smallbusiness/reusable/form_editor/bloc/form_editor_bloc.dart';
import 'package:smallbusiness/reusable/user_actions/models.dart';
import 'package:smallbusiness/user_actions/company_save.dart';

class CompanyEditBloc extends FormEditorBloc {
  final SbmContext sbmContext;

  CompanyEditBloc(
    this.sbmContext,
    DocumentReference<Map<String, dynamic>>? editingRef,
  ) : super(editingRef);

  @override
  Future<ActionResult> performSave(Map<String, dynamic> value) async {
    CompanySaveAction companySaveAction =
        CompanySaveAction(sbmContext.firestore, sbmContext.userRef);
    Company company = Company(companyLabel: value["companyLabel"]);
    return companySaveAction
        .performAction(CompanySaveModel(editingRef, company));
  }
}
