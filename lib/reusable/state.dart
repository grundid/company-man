import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smallbusiness/reusable/utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

@immutable
class AppState {}

class InProgress extends AppState {}

class ErrorState extends AppState {}

class Initialized extends AppState {}

class ActionReady extends Initialized {}

class ActionDone extends AppState {}

class ActionError extends ErrorState {
  final String? errorMessage;
  final bool fatal;

  ActionError({this.errorMessage, this.fatal = true});
}

class AppCubit extends Cubit<AppState> {
  AppCubit(super.initialState);

  void resetAfterError() {}
}

class ActionBlocConsumer<T extends AppCubit> extends BlocConsumer<T, AppState> {
  ActionBlocConsumer(
      {super.key,
      String? Function(BuildContext context, ActionError state)? errorBuilder,
      required super.builder})
      : super(listener: (context, state) async {
          if (state is ActionError) {
            String errorMessage =
                errorBuilder?.call(context, state) ?? "${state.errorMessage}";
            await showInfoDialog(
                context, AppLocalizations.of(context)!.fehler, errorMessage);
            if (state.fatal) {
              Navigator.pop(context);
            } else {
              context.read<T>().resetAfterError();
            }
          } else if (state is ActionDone) {
            Navigator.pop(context);
          }
        });
}
