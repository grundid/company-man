#!/bin/bash
# flutter clean
flutter build apk

firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk --app 1:582682220949:android:17f646ad65f1747bad3e9c --groups "intern" --release-notes-file release_notes.txt
