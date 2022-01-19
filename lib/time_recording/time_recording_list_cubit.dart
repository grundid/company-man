import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/time_recording/models.dart';

part 'time_recording_list_state.dart';

class TimeRecordingListCubit extends Cubit<TimeRecordingListState> {
  final SbmContext sbmContext;
  TimeRecordingListCubit(this.sbmContext)
      : super(TimeRecordingListInProgress());
}
