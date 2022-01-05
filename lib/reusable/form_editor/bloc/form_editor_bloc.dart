import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:smallbusiness/reusable/user_actions/models.dart';

part 'form_editor_event.dart';
part 'form_editor_state.dart';

abstract class FormEditorBloc extends Bloc<FormEditorEvent, FormEditorState> {
  DocumentReference<Map<String, dynamic>>? editingRef;
  final formKey = GlobalKey<FormBuilderState>();
  //Map<String, dynamic>? savedFormValues;
  dynamic fieldData;

  bool get isNew => editingRef == null;

  FormEditorBloc(this.editingRef) : super(FormEditorInitial()) {
    on<FormEditorSaveEvent>((event, emit) async {
      emit(FormEditorInProgress());
      ActionResult result = await performSave(event.formValues);
      if (result != null) {
        emit(FormEditorDone(result));
      }
    });
    on<FormEditorDeleteEvent>((event, emit) async {
      emit(FormEditorInProgress());
      ActionResult result = await performDelete();
      if (result != null) {
        emit(FormEditorDone(result));
      }
    });
    on<FormEditorLoadDataEvent>((event, emit) async {
      emit(FormEditorInProgress());
      fieldData = await readFieldData();
      final data = await readFormData();
      if (data != null) {
        emit(createFormEditorInitializedState(data, newEntry: false));
      }
    });
    on<FormEditorNewDataEvent>((event, emit) async {
      emit(FormEditorInProgress());
      fieldData = await readFieldData();
      emit(createFormEditorInitializedState(createEmptyInputValues(),
          newEntry: true));
    });
    on<FormEditorErrorEvent>((event, emit) async {
      emit(FormEditorError(
          event.errorMessage, formKey, formKey.currentState!.value));
    });
    if (isNew) {
      add(FormEditorNewDataEvent());
    } else {
      add(FormEditorLoadDataEvent());
    }
  }

  bool isNewEntryState() {
    if (state is FormEditorInitialized) {
      return (state as FormEditorInitialized).newEntry;
    } else {
      return false;
    }
  }

  Future<ActionResult> performSave(Map<String, dynamic> value);
  Future<ActionResult> performDelete() async {
    return ActionResult.emptyOk();
  }

  Future<Map<String, dynamic>?> readFormData() async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await editingRef!.get();
    return snapshot.data();
  }

  Map<String, dynamic> createEmptyInputValues() {
    return {};
  }

  /// read select lists or something like that
  Future<dynamic> readFieldData() async {
    return null;
  }

  @mustCallSuper
  FormEditorInitialized createFormEditorInitializedState(
      Map<String, dynamic> formValues,
      {bool? newEntry,
      bool editable = true}) {
    return FormEditorInitialized(formKey, formValues,
        newEntry: newEntry ?? isNewEntryState(), fieldData: fieldData);
  }
}
