import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:smallbusiness/time_recording/form_builder_time_editor.dart';
import 'package:smallbusiness/time_recording/models.dart';
import 'package:smallbusiness/time_recording/utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

DateFormat hmFormat = DateFormat.Hm();

class FormBuilderPauseEditor extends FormBuilderField<List<Pause>> {
  final DateTime workStartDate;

  FormBuilderPauseEditor(
      {super.key,
      required super.name,
      required this.workStartDate,
      super.decoration,
      super.validator})
      : super(builder: (FormFieldState field) {
          _FormBuilderPauseEditorState state =
              field as _FormBuilderPauseEditorState;
          return InputDecorator(
            decoration: state.decoration,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              for (Pause pause in state.value ?? [])
                PauseDisplay(
                  pause: pause,
                  onDelete: () {
                    state.deletePause(pause);
                  },
                ),
              ButtonBar(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        state.showAddDialog();
                      },
                      child: Text(
                          AppLocalizations.of(state.context)!.pauseErfassen)),
                ],
              ),
            ]),
          );
        });

  @override
  FormBuilderFieldState<FormBuilderField<List<Pause>>, List<Pause>>
      createState() {
    return _FormBuilderPauseEditorState();
  }
}

class _FormBuilderPauseEditorState
    extends FormBuilderFieldState<FormBuilderPauseEditor, List<Pause>> {
  deletePause(Pause pause) {
    value?.remove(pause);
    didChange(value);
  }

  showAddDialog() async {
    Pause? pause = await showDialog(
      context: context,
      builder: (context) {
        Map<String, dynamic> formValues = {
          "from": createFromNow(minuteStep: 1)
        };
        GlobalKey<FormBuilderState> formKey = GlobalKey();
        return AlertDialog(
          content: FormBuilder(
            key: formKey,
            initialValue: formValues,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FormBuilderTimeEditor(
                  minuteStep: 1,
                  name: "from",
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.pauseVon),
                  timeType: TimeType.from,
                ),
                FormBuilderTimeEditor(
                  minuteStep: 1,
                  name: "to",
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.pauseBis,
                      errorMaxLines: 2),
                  timeType: TimeType.to,
                  validator: FormBuilderValidators.compose(
                    [
                      FormBuilderValidators.required(context),
                      (value) {
                        if (value != null) {
                          TimeOfDay from =
                              formKey.currentState!.fields["from"]!.value;
                          TimeOfDay to = value;

                          DateTime fromDateTime =
                              createFrom(widget.workStartDate, from);
                          DateTime toDateTime =
                              createTo(widget.workStartDate, from, to)!;
                          Duration workDuration =
                              toDateTime.difference(fromDateTime);
                          if (workDuration.inMinutes < 15) {
                            return AppLocalizations.of(context)!
                                .diePauseMussMin15Minutenbetragen;
                          }
                        }
                        return null;
                      }
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  if (formKey.currentState!.saveAndValidate()) {
                    TimeOfDay from = formKey.currentState!.value["from"];
                    TimeOfDay to = formKey.currentState!.value["to"];

                    DateTime fromDateTime =
                        createFrom(widget.workStartDate, from);
                    DateTime toDateTime =
                        createTo(widget.workStartDate, from, to)!;

                    Navigator.pop(
                        context, Pause(from: fromDateTime, to: toDateTime));
                  }
                },
                child: Text(AppLocalizations.of(context)!.speichern))
          ],
        );
      },
    );
    if (pause != null) {
      List<Pause> pauses = value ?? [];
      pauses.add(pause);
      pauses.sort();
      didChange(pauses);
    }
  }
}

class PauseDisplay extends StatelessWidget {
  final Pause pause;
  final Function() onDelete;

  const PauseDisplay({super.key, required this.pause, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Text(
                "${hmFormat.format(pause.from)} - ${hmFormat.format(pause.to)}")),
        Expanded(
            child: Text(
                "(${fromDuration(pause.to.difference(pause.from)).getFormatted()})")),
        IconButton(onPressed: onDelete, icon: Icon(Icons.delete))
      ],
    );
  }
}
