import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:smallbusiness/auth/app_context.dart';

part 'app_status_state.dart';

class AppStatusCubit extends Cubit<AppStatusState> {
  final Connectivity _connectivity = Connectivity();
  final SbmContext sbmContext;
  StreamSubscription? appStatusSubscription;

  AppStatusCubit(this.sbmContext) : super(AppStatusInProgress()) {
    _init();
  }

  _init() async {
    String os = "dev";
    String appVersion = "";
    String projectVersion = "";
    if (kIsWeb) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      projectVersion = packageInfo.version;
      os = "web";
    } else if (Platform.isAndroid) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      projectVersion = packageInfo.version;
      os = "android";
    } else if (Platform.isIOS) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      projectVersion = packageInfo.version;
      os = "ios";
    }
    appVersion = "$os-$projectVersion";

    try {
      ConnectivityResult result = await _connectivity.checkConnectivity();
      if (result == ConnectivityResult.none) {
        emit(AppStatusInitialized(null, appVersion, true));
        return;
      }
    } catch (e) {
      emit(AppStatusInitialized(null, appVersion, true));
      return;
    }

    appStatusSubscription = sbmContext.queryBuilder
        .clientAppVersion(appVersion)
        .snapshots()
        .listen((final snapshot) {
      String? appStatus;
      if (snapshot.exists) {
        appStatus = snapshot.data()!["status"];
      } else {
        appStatus = null;
      }

      log("app status $appStatus, app version $appVersion");
      emit(AppStatusInitialized(appStatus, appVersion, false));
    }, onError: (error) {
      log(error.toString());
      if (error is FirebaseException && error.code == "permission-denied") {
        // this can happen after using the emulator. sign out the user 
        sbmContext.auth.signOut();
      } else {
        emit(AppStatusInitialized(null, error.toString(), false));
      }
    });
  }

  retry() async {
    await appStatusSubscription?.cancel();
    _init();
  }

  @override
  Future<void> close() async {
    await appStatusSubscription?.cancel();
    return super.close();
  }
}
