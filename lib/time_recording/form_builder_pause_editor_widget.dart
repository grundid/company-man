import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/form.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:smallbusiness/time_recording/models.dart';

class FormBuilderPauseEditor extends FormBuilderField<List<Pause>> {
  FormBuilderPauseEditor(
      {super.key, required super.name, super.decoration, super.validator})
      : super(builder: (FormFieldState field) {
          _FormBuilderPauseEditorState state =
              field as _FormBuilderPauseEditorState;
          return InputDecorator(
            decoration: state.decoration,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ButtonBar(
                children: [
                  ElevatedButton(
                      onPressed: () {}, child: Text("+ Pause erfassen")),
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

class PauseController {
  final TextEditingController fromController;
  final TextEditingController toController;

  PauseController(this.fromController, this.toController);
}

final DateFormat _dateFormat = DateFormat.Hm();
String _formatted(DateTime? value) =>
    value != null ? _dateFormat.format(value) : "";

DateTime? _parse(String input) {
  try {
    if (input.length == 1 || input.indexOf(":") == 1) {
      input = "0$input";
    }
    if (input.endsWith(":")) {
      input += "00";
    } else if (input.indexOf(":") == input.length - 2) {
      input += "0";
    }
    DateTime result = DateTime.parse("0001-01-01 $input");
    if (result.year == 1 && result.month == 1 && result.day == 1) {
      return result;
    } else {
      return null;
    }
  } on Exception catch (_) {
    return null;
  }
}

class _FormBuilderPauseEditorState
    extends FormBuilderFieldState<FormBuilderPauseEditor, List<Pause>> {
  List<PauseController> pauses = [];

  @override
  void initState() {
    super.initState();
    if (true == value?.isNotEmpty) {
      for (Pause pause in value!) {}
    }
  }
}
