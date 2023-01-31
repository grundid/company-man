#!/bin/bash

flutter build ipa --release
xcrun altool --upload-app --type ios -f build/ios/ipa/*.ipa --apiKey $IOS_API_KEY --apiIssuer $IOS_API_ISSUER --show-progress
