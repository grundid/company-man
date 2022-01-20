import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:routemaster/routemaster.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/reusable/loader.dart';
import 'package:smallbusiness/reusable/responsive_body.dart';
import 'package:smallbusiness/time_recording/time_recording_cubit.dart';

class TimeRecordingWidget extends StatelessWidget {
  final SbmContext sbmContext;
  final String? timeRecordingId;

  TimeRecordingWidget(
      {Key? key, required this.sbmContext, this.timeRecordingId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Zeiterfassung"),
      ),
      body: BlocProvider(
        create: (context) => TimeRecordingCubit(sbmContext),
        child: BlocConsumer<TimeRecordingCubit, TimeRecordingState>(
          listener: (context, state) {
            if (state is TimeRecordingDone) {
              Routemaster.of(context).pop(true);
            } else if (state is TimeRecordingInitialized &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            }
          },
          builder: (context, state) {
            return state is TimeRecordingInitialized
                ? ResponsiveBody(
                    child: FormBuilder(
                      key: state.formKey,
                      initialValue: state.formValues,
                      child: Column(
                        children: [
                          FormBuilderDateTimePicker(
                            name: "fromDate",
                            initialValue: state.fromDate,
                            format: DateFormat.yMMMMEEEEd(),
                            inputType: InputType.date,
                            decoration: InputDecoration(label: Text("Datum")),
                            onChanged: (value) {
                              if (value != null) {
                                context.read<TimeRecordingCubit>().fromDate =
                                    value;
                              }
                            },
                          ),
                          TimeEnterWidget(
                            timeOfDay: state.from,
                            label: "Gekommen",
                            onHourDec: () {
                              context
                                  .read<TimeRecordingCubit>()
                                  .decHour(TimeType.from);
                            },
                            onHourInc: () {
                              context
                                  .read<TimeRecordingCubit>()
                                  .incHour(TimeType.from);
                            },
                            onMinuteDec: () {
                              context
                                  .read<TimeRecordingCubit>()
                                  .decMinute(TimeType.from);
                            },
                            onMinuteInc: () {
                              context
                                  .read<TimeRecordingCubit>()
                                  .incMinute(TimeType.from);
                            },
                          ),
                          TimeEnterWidget(
                            timeOfDay: state.to,
                            label: "Gegangen",
                            onHourDec: () {
                              context
                                  .read<TimeRecordingCubit>()
                                  .decHour(TimeType.to);
                            },
                            onHourInc: () {
                              context
                                  .read<TimeRecordingCubit>()
                                  .incHour(TimeType.to);
                            },
                            onMinuteDec: () {
                              context
                                  .read<TimeRecordingCubit>()
                                  .decMinute(TimeType.to);
                            },
                            onMinuteInc: () {
                              context
                                  .read<TimeRecordingCubit>()
                                  .incMinute(TimeType.to);
                            },
                          ),
                          Text(
                            "Arbeitszeit: ${state.workingTime}",
                            style: Theme.of(context).textTheme.headline6!,
                          ),
/*                          FormBuilderTextField(
                            name: "cash",
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                                label: Text(
                                  "Bargeld",
                                ),
                                suffixText: "EUR"),
                          ),
                          FormBuilderTextField(
                            name: "mileage",
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                                label: Text(
                                  "Kilometerstand am Ende der Schicht",
                                ),
                                suffixText: "KM"),
                          ),*/
                          FormBuilderTextField(
                            name: "message",
                            decoration: InputDecoration(
                                label: Text(
                                  "Nachricht",
                                ),
                                helperMaxLines: 3,
                                helperText:
                                    "Diese Nachricht wird zusammen mit der Zeiterfassung an den Manager geschickt."),
                          ),
                          ButtonBar(
                            children: [
                              TextButton(
                                  onPressed: () {
                                    context.read<TimeRecordingCubit>().save();
                                  },
                                  child: Text("Speichern")),
                              ElevatedButton(
                                  onPressed: () {
                                    context.read<TimeRecordingCubit>().finish();
                                  },
                                  child: Text("Abschließen"))
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                : LoadingAnimationScreen();
          },
        ),
      ),
    );
  }
}

class TimeEnterWidget extends StatelessWidget {
  final String label;
  final TimeOfDay? timeOfDay;
  final Function() onHourInc;
  final Function() onHourDec;
  final Function() onMinuteInc;
  final Function() onMinuteDec;

  TimeEnterWidget(
      {Key? key,
      required this.label,
      required this.timeOfDay,
      required this.onHourDec,
      required this.onHourInc,
      required this.onMinuteDec,
      required this.onMinuteInc})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(label: Text(label), border: InputBorder.none),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _NumberWidget(
            value: timeOfDay?.hour,
            onDec: onHourDec,
            onInc: onHourInc,
          ),
          Text(
            ":",
            style: Theme.of(context).textTheme.headline2!,
          ),
          _NumberWidget(
            value: timeOfDay?.minute,
            onDec: onMinuteDec,
            onInc: onMinuteInc,
          )
        ],
      ),
    );
  }
}

final NumberFormat _numberFormat = NumberFormat("00");

class _NumberWidget extends StatelessWidget {
  final int? value;
  final Function() onInc;
  final Function() onDec;

  const _NumberWidget({
    Key? key,
    required this.value,
    required this.onInc,
    required this.onDec,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: onInc,
          child: Text(
            "+",
            style: TextStyle(fontSize: 32),
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
            style: Theme.of(context).textTheme.headline2!,
          ),
        ),
        TextButton(
          onPressed: onDec,
          child: Text(
            "-",
            style: TextStyle(fontSize: 32),
          ),
        ),
      ],
    );
  }
}
