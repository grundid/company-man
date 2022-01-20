import 'package:bloc/bloc.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/time_recording/models.dart';
import 'package:smallbusiness/time_recording/utils.dart';

part 'time_recording_list_state.dart';

class GroupedTimeRecording {
  final String label;
  bool expanded;
  final List<TimeRecording> timeRecordings;
  HoursMinutes totalDuration = HoursMinutes.zero();

  GroupedTimeRecording(this.label, this.expanded, this.timeRecordings);

  addTimeRecording(TimeRecording timeRecording) {
    timeRecordings.add(timeRecording);
    if (timeRecording.to != null) {
      Duration duration = timeRecording.to!.difference(timeRecording.from);
      totalDuration += HoursMinutes.fromDuration(duration);
    }
  }
}

class TimeRecordingListCubit extends Cubit<TimeRecordingListState> {
  final SbmContext sbmContext;
  late List<GroupedTimeRecording> groups;

  TimeRecordingListCubit(this.sbmContext)
      : super(TimeRecordingListInProgress()) {
    _init();
  }

  _init() async {
    emit(TimeRecordingListInProgress());

    final querySnapshot = await sbmContext.queryBuilder
        .timeRecordingForEmployeeRef(
            companyRef: sbmContext.companyRef!,
            employeeRef: sbmContext.employeeRef!)
        .get();

    List<TimeRecording> timeRecordings = querySnapshot.docs
        .map((e) => TimeRecording.fromSnapshot(e.reference, e.data()))
        .toList();
    timeRecordings.sort((t1, t2) => t2.from.compareTo(t1.from));

    DateFormat monthYear = DateFormat.yMMMM();

    Map<String, GroupedTimeRecording> perMonth = {};
    groups = [];
    int currentMonth = DateTime.now().month;
    for (TimeRecording timeRecording in timeRecordings) {
      String label = monthYear.format(timeRecording.from);
      bool expanded = timeRecording.from.month == currentMonth;
      GroupedTimeRecording groupedTimeRecording =
          perMonth.putIfAbsent(label, () {
        final result = GroupedTimeRecording(label, expanded, []);
        groups.add(result);
        return result;
      });
      groupedTimeRecording.addTimeRecording(timeRecording);
    }

    emit(TimeRecordingListInitialized(groups));
  }

  void update() {
    _init();
  }

  void setExpanded(int panelIndex, bool isExpanded) {
    groups[panelIndex].expanded = !isExpanded;
    emit(TimeRecordingListInitialized(groups));
  }
}
