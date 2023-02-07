import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/reusable/state.dart';
import 'package:smallbusiness/reusable/user_actions/models.dart';
import 'package:smallbusiness/time_recording/models.dart';
import 'package:smallbusiness/time_recording/utils.dart';

class TimeRecordingInitialized extends Initialized {
  final TimeRecording? initializedTimeRecording;
  final GlobalKey<FormBuilderState> formKey;
  final DynamicMap formValues;

  TimeRecordingInitialized({
    this.initializedTimeRecording,
    required this.formKey,
    required this.formValues,
  });
}

class TimeRecordingCubit extends Cubit<AppState> {
  final SbmContext sbmContext;
  final GlobalKey<FormBuilderState> formKey = GlobalKey();
  DocumentReference<DynamicMap>? timeRecordingRef;

  TimeRecordingCubit(this.sbmContext, {String? timeRecordingId})
      : super(InProgress()) {
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
    DateTime now = DateTime.now();
    DateTime fromDate = DateTime(now.year, now.month, now.day);
    TimeOfDay from = createFromNow();
    DynamicMap formValues = {
      "fromDate": fromDate,
      "fromTime": from,
    };
    emit(TimeRecordingInitialized(formKey: formKey, formValues: formValues));
  }

  void _initFromSnapshot(
      DocumentReference<DynamicMap> timeRecordingRef, DynamicMap data) {
    TimeRecording timeRecording =
        TimeRecording.fromSnapshot(timeRecordingRef, data);
    DateTime fromDate = DateTime(timeRecording.from.year,
        timeRecording.from.month, timeRecording.from.day);
    TimeOfDay from = TimeOfDay.fromDateTime(timeRecording.from);
    TimeOfDay? to = timeRecording.to != null
        ? TimeOfDay.fromDateTime(timeRecording.to!)
        : null;
    DynamicMap formValues = {
      "message": timeRecording.message,
      "managerMessage": timeRecording.managerMessage,
      "fromDate": fromDate,
      "fromTime": from,
      "toTime": to,
      "pauses": timeRecording.pauses
    };
    emit(TimeRecordingInitialized(
        initializedTimeRecording: timeRecording,
        formKey: formKey,
        formValues: formValues));
  }
}
