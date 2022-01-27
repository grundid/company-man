#!/bin/bash

# cider bump build
# git commit -a -m "version increase for release"
# git push

VERSION=$(cider version)

echo "New version: ${VERSION}"
echo "Neue Web Version wird registriert..."
curl -H "Authorization: asD873ekhJgaQd654" -X POST "https://europe-west1-smallbusiness-prd.cloudfunctions.net/appVersion?os=web&version=$VERSION"
echo "Neue Android Version wird registriert..."
curl -H "Authorization: asD873ekhJgaQd654" -X POST "https://europe-west1-smallbusiness-prd.cloudfunctions.net/appVersion?os=android&version=$VERSION"
echo "Neue iOS Version wird registriert..."
curl -H "Authorization: asD873ekhJgaQd654" -X POST "https://europe-west1-smallbusiness-prd.cloudfunctions.net/appVersion?os=ios&version=$VERSION"
