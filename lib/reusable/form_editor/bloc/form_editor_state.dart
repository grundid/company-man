part of 'form_editor_bloc.dart';

@immutable
abstract class FormEditorState {}

class FormEditorInitial extends FormEditorState {}

class FormEditorInProgress extends FormEditorState {}

class FormEditorDone extends FormEditorState {
  final ActionResult actionResult;

  FormEditorDone(this.actionResult);
}

class FormEditorInitialized extends FormEditorState {
  final GlobalKey<FormBuilderState> formKey;
  final Map<String, dynamic> formValues;
  final bool editable;
  final bool newEntry;
  final dynamic fieldData;

  FormEditorInitialized(this.formKey, this.formValues,
      {this.editable = true, this.newEntry = true, this.fieldData});
}

class FormEditorError extends FormEditorInitialized {
  final String errorMessage;
  FormEditorError(this.errorMessage, GlobalKey<FormBuilderState> formKey,
      Map<String, dynamic> formValues,
      {bool editable = true, bool newEntry = true})
      : super(formKey, formValues, editable: editable, newEntry: newEntry);
}
