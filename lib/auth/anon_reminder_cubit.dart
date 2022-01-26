import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'anon_reminder_state.dart';

class AnonReminderCubit extends Cubit<AnonReminderState> {
  AnonReminderCubit() : super(AnonReminderInitial());
}
