#!/bin/bash
# flutter clean
flutter build ios

cd build/ios/iphoneos
rm -fr Payload
mkdir Payload
mv Runner.app Payload/
zip -r app.ipa Payload/

cd ../../../

firebase appdistribution:distribute build/ios/iphoneos/app.ipa  --app 1:582682220949:ios:2cc0f662a8a9b9d1ad3e9c --groups "intern" --release-notes-file release_notes.txt
