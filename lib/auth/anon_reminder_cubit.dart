import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/auth/models.dart';
import 'package:smallbusiness/user_actions/anon_reminder_update.dart';

part 'anon_reminder_state.dart';

class AnonReminderCubit extends Cubit<AnonReminderState> {
  final SbmContext sbmContext;

  AnonReminderCubit(this.sbmContext) : super(AnonReminderInProgress()) {
    _init();
  }

  _init() async {
    if (sbmContext.user.isAnonymous) {
      final documentSnapshot = await sbmContext.userRef.get();
      SbmUserModel user = SbmUserModel.fromData(documentSnapshot.data()!);
      DateTime anonReminder =
          user.anonReminder ?? DateTime.now().subtract(Duration(minutes: 1));
      bool showWarning = anonReminder.isBefore(DateTime.now());
      emit(AnonReminderInitialized(showWarning));
    }
  }

  remindMeLater() async {
    emit(AnonReminderInProgress());
    AnonReminderUpdateAction action =
        AnonReminderUpdateAction(sbmContext.firestore, sbmContext.userRef);
    await action.performAction(AnonReminderUpdateModel(
        sbmContext.userRef, DateTime.now().add(Duration(days: 7))));
    _init();
  }
}
