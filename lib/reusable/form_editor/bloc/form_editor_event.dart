part of 'form_editor_bloc.dart';

@immutable
abstract class FormEditorEvent {
  FormEditorEvent withValues(
      {required Map<String, dynamic> formValues,
      Map<String, dynamic>? confirmValues}) {
    return this;
  }
}

class FormEditorNewDataEvent extends FormEditorEvent {}

class FormEditorLoadDataEvent extends FormEditorEvent {}

class FormEditorClearErrorEvent extends FormEditorEvent {}

class FormEditorShowFormAgainEvent extends FormEditorEvent {}

class FormEditorErrorEvent extends FormEditorEvent {
  final String errorMessage;

  FormEditorErrorEvent(this.errorMessage);
}

class FormEditorSaveEvent extends FormEditorEvent {
  final Map<String, dynamic> formValues;
  final Map<String, dynamic>? confirmValues;

  FormEditorSaveEvent({required this.formValues, this.confirmValues});

  @override
  FormEditorEvent withValues(
      {required Map<String, dynamic> formValues,
      Map<String, dynamic>? confirmValues}) {
    return FormEditorSaveEvent(
        formValues: formValues, confirmValues: confirmValues);
  }
}

class FormEditorDeleteEvent extends FormEditorEvent {}
