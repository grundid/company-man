import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/reusable/user_actions/models.dart';
import 'package:smallbusiness/time_recording/models.dart';
import 'package:smallbusiness/time_recording/time_recording_status_cubit.dart';
import 'package:smallbusiness/time_recording/utils.dart';
import 'package:smallbusiness/user_actions/time_recording_save.dart';

part 'time_recording_state.dart';

class TimeRecordingCubit extends Cubit<TimeRecordingState> {
  final SbmContext sbmContext;
  final GlobalKey<FormBuilderState> formKey = GlobalKey();
  DocumentReference<DynamicMap>? timeRecordingRef;
  DynamicMap formValues = {};
  final TimeRecordingStatusCubit statusCubit;
  TimeRecording? knownTimeRecording;

  TimeRecordingCubit(this.sbmContext, this.statusCubit,
      {String? timeRecordingId})
      : super(TimeRecordingInProgress()) {
    if (timeRecordingId != null) {
      timeRecordingRef = sbmContext.queryBuilder
          .timeRecordingsCollection()
          .doc(timeRecordingId);
    }
    _init();
  }

  _init() async {
    if (timeRecordingRef != null) {
      final documentSnapshot = await timeRecordingRef!.get();
      if (documentSnapshot.exists) {
        _initFromSnapshot(timeRecordingRef!, documentSnapshot.data()!);
      } else {
        _initNew();
      }
    } else {
      QuerySnapshot<DynamicMap> querySnapshot = await sbmContext.queryBuilder
          .latestTimeRecordingForEmployeeRef(
              sbmContext.companyRef!, sbmContext.employeeRef!)
          .get();
      if (querySnapshot.size == 0) {
        _initNew();
      } else {
        final documentSnapshot = querySnapshot.docs.first;
        timeRecordingRef = documentSnapshot.reference;
        _initFromSnapshot(documentSnapshot.reference, documentSnapshot.data());
      }
    }
  }

  void _initNew() {
    DateTime fromDate = DateTime.now();
    TimeOfDay from = createFromNow();
    formValues = {
      "fromDate": fromDate,
      "fromTime": from,
    };
    emitInitialized();
  }

  void _initFromSnapshot(
      DocumentReference<DynamicMap> timeRecordingRef, DynamicMap data) {
    TimeRecording timeRecording =
        TimeRecording.fromSnapshot(timeRecordingRef, data);
    knownTimeRecording = timeRecording;
    DateTime fromDate = DateTime(timeRecording.from.year,
        timeRecording.from.month, timeRecording.from.day);
    TimeOfDay from = TimeOfDay.fromDateTime(timeRecording.from);
    TimeOfDay? to = timeRecording.to != null
        ? TimeOfDay.fromDateTime(timeRecording.to!)
        : null;
    formValues = {
      "message": timeRecording.message,
      "managerMessage": timeRecording.managerMessage,
      "fromDate": fromDate,
      "fromTime": from,
      "toTime": to,
      "pauses": timeRecording.pauses
    };
    emitInitialized();
    statusCubit.update(WorkTimeState.fromFormValues(formValues));
  }

  void emitInitialized({String? errorMessage}) {
    emit(TimeRecordingInitialized(
        formKey: formKey, formValues: formValues, errorMessage: errorMessage));
  }

  TimeRecording _prepareTimeRecording(
      Map<String, dynamic> formValues, bool finalized) {
    TimeRecording timeRecording = TimeRecording(
        companyRef: sbmContext.companyRef!,
        employeeRef: knownTimeRecording?.employeeRef ?? sbmContext.employeeRef!,
        from: createFrom(formValues["fromDate"], formValues["fromTime"]),
        to: createTo(formValues["fromDate"], formValues["fromTime"],
            formValues["toTime"]),
        pauses: formValues["pauses"] ?? [],
        message: formValues["message"],
        managerMessage: formValues["managerMessage"],
        finalized: finalized,
        created: DateTime.now(),
        finalizedDate: finalized ? DateTime.now() : null);
    return timeRecording;
  }

  save(Map<String, dynamic> formValues, bool finalized) async {
    emit(TimeRecordingInProgress());
    TimeRecording timeRecording = _prepareTimeRecording(formValues, finalized);
    TimeRecordingSaveModel model =
        TimeRecordingSaveModel(timeRecordingRef, timeRecording);

    TimeRecordingSaveAction action =
        TimeRecordingSaveAction(sbmContext.firestore, sbmContext.userRef);

    await action.performAction(model);
    emit(TimeRecordingDone());
  }

  void reset(Map<String, dynamic> value) {
    save(formValues, false);
  }
}
