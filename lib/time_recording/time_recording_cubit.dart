import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/reusable/user_actions/models.dart';
import 'package:smallbusiness/time_recording/models.dart';
import 'package:smallbusiness/time_recording/utils.dart';
import 'package:smallbusiness/user_actions/time_recording_save.dart';

part 'time_recording_state.dart';

enum TimeType { from, to }
const int minuteStep = 5;

class TimeRecordingCubit extends Cubit<TimeRecordingState> {
  final SbmContext sbmContext;
  final GlobalKey<FormBuilderState> formKey = GlobalKey();
  late DateTime fromDate;
  late TimeOfDay from;
  TimeOfDay? to;
  DocumentReference<DynamicMap>? timeRecordingRef;
  DynamicMap formValues = {};

  TimeRecordingCubit(this.sbmContext, {String? timeRecordingId})
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
    fromDate = DateTime.now();
    int hour = fromDate.hour;
    int minute = (fromDate.minute / 5).floor() * 5;
    from = TimeOfDay(hour: hour, minute: minute);
    emitInitialized();
  }

  void _initFromSnapshot(
      DocumentReference<DynamicMap> timeRecordingRef, DynamicMap data) {
    TimeRecording timeRecording =
        TimeRecording.fromSnapshot(timeRecordingRef, data);
    fromDate = DateTime(timeRecording.from.year, timeRecording.from.month,
        timeRecording.from.day);
    from = TimeOfDay.fromDateTime(timeRecording.from);
    to = timeRecording.to != null
        ? TimeOfDay.fromDateTime(timeRecording.to!)
        : null;
    formValues["message"] = timeRecording.message;
    emitInitialized();
  }

  DateTime nextDay(DateTime date) {
    DateTime lastHourOfDay = DateTime(date.year, date.month, date.day, 23);
    return lastHourOfDay.add(Duration(hours: 1));
  }

  DateTime createFrom() {
    return DateTime(
        fromDate.year, fromDate.month, fromDate.day, from.hour, from.minute);
  }

  DateTime createTo(TimeOfDay to) {
    DateTime myTo = DateTime(fromDate.year, fromDate.month, fromDate.day);
    if (to.isBefore(from)) {
      myTo = nextDay(myTo);
    }
    return DateTime(myTo.year, myTo.month, myTo.day, to.hour, to.minute);
  }

  void emitInitialized({String? errorMessage}) {
    String workingTimeLabel = "-";
    if (to != null) {
      DateTime myFrom = createFrom();
      DateTime myTo = createTo(to!);

      Duration duration = myTo.difference(myFrom);
      TimeOfDay workingHours = fromDuration(duration);
      workingTimeLabel = workingHours.getFormatted();
    }

    emit(TimeRecordingInitialized(
        formKey: formKey,
        fromDate: fromDate,
        from: from,
        to: to,
        formValues: formValues,
        workingTime: workingTimeLabel,
        errorMessage: errorMessage));
  }

  TimeOfDay _incHour(TimeOfDay timeOfDay) {
    int hour = timeOfDay.hour;
    hour++;
    if (hour > 23) {
      hour = 0;
    }
    return TimeOfDay(hour: hour, minute: timeOfDay.minute);
  }

  TimeOfDay _decHour(TimeOfDay timeOfDay) {
    int hour = timeOfDay.hour;
    hour--;
    if (hour < 0) {
      hour = 23;
    }
    return TimeOfDay(hour: hour, minute: timeOfDay.minute);
  }

  TimeOfDay _initTo() {
    DateTime now = DateTime.now();
    int minute = (now.minute / minuteStep).ceil() * minuteStep;
    if (minute > 59) {
      return _incHour(TimeOfDay(hour: now.hour, minute: 0));
    } else {
      return TimeOfDay(hour: now.hour, minute: minute);
    }
  }

  incHour(TimeType timeType) {
    switch (timeType) {
      case TimeType.from:
        from = _incHour(from);
        break;
      case TimeType.to:
        if (to == null) {
          to = _initTo();
        } else {
          to = _incHour(to!);
        }
        break;
    }
    emitInitialized();
  }

  decHour(TimeType timeType) {
    switch (timeType) {
      case TimeType.from:
        from = _decHour(from);
        break;
      case TimeType.to:
        if (to == null) {
          to = _initTo();
        } else {
          to = _decHour(to!);
        }
        break;
    }
    emitInitialized();
  }

  TimeOfDay _incMinute(TimeOfDay timeOfDay) {
    int minute = timeOfDay.minute;
    minute += minuteStep;
    if (minute > 59) {
      return _incHour(TimeOfDay(hour: timeOfDay.hour, minute: 0));
    } else {
      return TimeOfDay(hour: timeOfDay.hour, minute: minute);
    }
  }

  TimeOfDay _decMinute(TimeOfDay timeOfDay) {
    int minute = timeOfDay.minute;
    minute -= minuteStep;
    if (minute < 0) {
      return _decHour(TimeOfDay(hour: timeOfDay.hour, minute: 60 - minuteStep));
    } else {
      return TimeOfDay(hour: timeOfDay.hour, minute: minute);
    }
  }

  incMinute(TimeType timeType) {
    switch (timeType) {
      case TimeType.from:
        from = _incMinute(from);
        break;
      case TimeType.to:
        if (to == null) {
          to = _initTo();
        } else {
          to = _incMinute(to!);
        }
        break;
    }
    emitInitialized();
  }

  decMinute(TimeType timeType) {
    switch (timeType) {
      case TimeType.from:
        from = _decMinute(from);
        break;
      case TimeType.to:
        if (to == null) {
          to = _initTo();
        } else {
          to = _decMinute(to!);
        }
        break;
    }
    emitInitialized();
  }

  TimeRecording _prepareTimeRecording(bool finalized) {
    TimeRecording timeRecording = TimeRecording(
        companyRef: sbmContext.companyRef!,
        employeeRef: sbmContext.employeeRef!,
        from: createFrom(),
        to: to != null ? createTo(to!) : null,
        pauses: [],
        message: formKey.currentState!.value["message"],
        finalized: finalized);
    return timeRecording;
  }

  save() async {
    emit(TimeRecordingInProgress());
    formKey.currentState!.save();
    TimeRecording timeRecording = _prepareTimeRecording(false);
    TimeRecordingSaveModel model =
        TimeRecordingSaveModel(timeRecordingRef, timeRecording);

    TimeRecordingSaveAction action =
        TimeRecordingSaveAction(sbmContext.firestore, sbmContext.userRef);

    await action.performAction(model);
    emit(TimeRecordingDone());
  }

  finish() async {
    if (to != null) {
      emit(TimeRecordingInProgress());
      formKey.currentState!.save();
      TimeRecording timeRecording = _prepareTimeRecording(true);
      if (timeRecording.to!.isAfter(DateTime.now().add(Duration(hours: 1)))) {
        emitInitialized(
            errorMessage:
                "Die Ende-Zeit darf nicht mehr als 1h in der Zukunft liegen");
      }

      TimeRecordingSaveModel model =
          TimeRecordingSaveModel(timeRecordingRef, timeRecording);

      TimeRecordingSaveAction action =
          TimeRecordingSaveAction(sbmContext.firestore, sbmContext.userRef);

      await action.performAction(model);
      emit(TimeRecordingDone());
    } else {
      emitInitialized(
          errorMessage:
              "Bitte Ende-Zeit eingeben um die Erfassung abzuschließen");
    }
  }
}
