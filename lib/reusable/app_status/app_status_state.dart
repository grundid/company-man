part of 'app_status_cubit.dart';

@immutable
abstract class AppStatusState {}

class AppStatusInProgress extends AppStatusState {}

class AppStatusInitialized extends AppStatusState {
  final String? appStatus;
  final String appVersion;
  final bool offline;

  AppStatusInitialized(this.appStatus, this.appVersion, this.offline);

  bool get isValid => (appStatus == "supported" || isOutdated) && !offline;

  bool get isOutdated => appStatus == "outdated";

  bool get isInvalid => appStatus == null || !isValid;
}
