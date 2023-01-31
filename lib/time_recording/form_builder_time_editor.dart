import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';

enum TimeType { from, to }

class FormBuilderTimeEditor extends FormBuilderField<TimeOfDay> {
  final TimeType timeType;
  final int minuteStep;

  FormBuilderTimeEditor(
      {super.key,
      required super.name,
      super.decoration,
      super.validator,
      this.minuteStep = 1,
      required this.timeType})
      : super(builder: (field) {
          _FormBuilderPauseEditorState state =
              field as _FormBuilderPauseEditorState;
          return TimeEnterWidget(
            timeOfDay: field.value,
            decoration: state.decoration,
            onHourDec: state.decHour,
            onHourInc: state.incHour,
            onMinuteDec: state.decMinute,
            onMinuteInc: state.incMinute,
          );
        });

  @override
  FormBuilderFieldState<FormBuilderField<TimeOfDay>, TimeOfDay> createState() {
    return _FormBuilderPauseEditorState();
  }
}

class _FormBuilderPauseEditorState
    extends FormBuilderFieldState<FormBuilderTimeEditor, TimeOfDay> {
  @override
  InputDecoration get decoration =>
      super.decoration.copyWith(border: InputBorder.none);

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
    int minute = (now.minute / widget.minuteStep).ceil() * widget.minuteStep;
    if (minute > 59) {
      return _incHour(TimeOfDay(hour: now.hour, minute: 0));
    } else {
      return TimeOfDay(hour: now.hour, minute: minute);
    }
  }

  incHour() {
    switch (widget.timeType) {
      case TimeType.from:
        didChange(_incHour(value!));
        break;
      case TimeType.to:
        if (value == null) {
          didChange(_initTo());
        } else {
          didChange(_incHour(value!));
        }
        break;
    }
  }

  decHour() {
    switch (widget.timeType) {
      case TimeType.from:
        didChange(_decHour(value!));
        break;
      case TimeType.to:
        if (value == null) {
          didChange(_initTo());
        } else {
          didChange(_decHour(value!));
        }
        break;
    }
  }

  TimeOfDay _incMinute(TimeOfDay timeOfDay) {
    int minute = timeOfDay.minute;
    minute += widget.minuteStep;
    if (minute > 59) {
      return _incHour(TimeOfDay(hour: timeOfDay.hour, minute: 0));
    } else {
      return TimeOfDay(hour: timeOfDay.hour, minute: minute);
    }
  }

  TimeOfDay _decMinute(TimeOfDay timeOfDay) {
    int minute = timeOfDay.minute;
    minute -= widget.minuteStep;
    if (minute < 0) {
      return _decHour(
          TimeOfDay(hour: timeOfDay.hour, minute: 60 - widget.minuteStep));
    } else {
      return TimeOfDay(hour: timeOfDay.hour, minute: minute);
    }
  }

  incMinute() {
    switch (widget.timeType) {
      case TimeType.from:
        didChange(_incMinute(value!));
        break;
      case TimeType.to:
        if (value == null) {
          didChange(_initTo());
        } else {
          didChange(_incMinute(value!));
        }
        break;
    }
  }

  decMinute() {
    switch (widget.timeType) {
      case TimeType.from:
        didChange(_decMinute(value!));
        break;
      case TimeType.to:
        if (value == null) {
          didChange(_initTo());
        } else {
          didChange(_decMinute(value!));
        }
        break;
    }
  }
}

class TimeEnterWidget extends StatelessWidget {
  final InputDecoration decoration;
  final TimeOfDay? timeOfDay;
  final Function() onHourInc;
  final Function() onHourDec;
  final Function() onMinuteInc;
  final Function() onMinuteDec;

  TimeEnterWidget(
      {Key? key,
      required this.decoration,
      required this.timeOfDay,
      required this.onHourDec,
      required this.onHourInc,
      required this.onMinuteDec,
      required this.onMinuteInc})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: decoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _NumberWidget(
            value: timeOfDay?.hour,
            minDeltaForAction: 6,
            onDec: onHourDec,
            onInc: onHourInc,
          ),
          Text(
            ":",
            style: Theme.of(context).textTheme.headlineMedium!,
          ),
          _NumberWidget(
            value: timeOfDay?.minute,
            minDeltaForAction: 2,
            onDec: onMinuteDec,
            onInc: onMinuteInc,
          )
        ],
      ),
    );
  }
}

final NumberFormat _numberFormat = NumberFormat("00");

// ignore: must_be_immutable
class _NumberWidget extends StatelessWidget {
  final int? value;
  final Function() onInc;
  final Function() onDec;
  final double minDeltaForAction;
  double deltaY = 0;

  _NumberWidget(
      {Key? key,
      required this.value,
      required this.onInc,
      required this.onDec,
      required this.minDeltaForAction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        deltaY += details.delta.dy;
        if (deltaY > minDeltaForAction) {
          onDec();
          deltaY = 0;
        } else if (deltaY < -minDeltaForAction) {
          onInc();
          deltaY = 0;
        }
      },
      child: Column(
        children: [
          IconButton(
            onPressed: onInc,
            icon: Icon(
              Icons.arrow_circle_up_outlined,
              color: Theme.of(context).primaryColor,
            ),
          ),
          Container(
            alignment: Alignment.center,
            width: 100,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.all(Radius.circular(8))),
            padding: EdgeInsets.all(8),
            child: Text(
              value != null ? _numberFormat.format(value) : "--",
              style: Theme.of(context).textTheme.headlineMedium!,
            ),
          ),
          IconButton(
            onPressed: onDec,
            icon: Icon(
              Icons.arrow_circle_down_outlined,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
