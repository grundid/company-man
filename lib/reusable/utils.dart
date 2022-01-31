import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:universal_html/html.dart' as html;

Future<String> findSystemLocale() {
  try {
    Intl.systemLocale = Intl.canonicalizedLocale(Platform.localeName);
  } catch (e) {
    if (kIsWeb) {
      Intl.systemLocale =
          Intl.canonicalizedLocale(html.window.navigator.language);
    } else {
      Intl.systemLocale = Intl.canonicalizedLocale("de_DE");
    }
  }
  return Future.value(Intl.systemLocale);
}

Future<void> showErrorMessage(BuildContext context, String message) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        scrollable: true,
        title: Text("Fehler"),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(message),
        ]),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Ok"),
          )
        ],
      );
    },
  );
}

Future<void> showInfoDialog(
    BuildContext context, String title, String content) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        scrollable: true,
        title: Text(title),
        content: SingleChildScrollView(child: Text(content)),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Ok"),
          )
        ],
      );
    },
  );
}

Future<bool?> showQueryDialog(
    BuildContext context, String title, String content,
    {bool yesNo = false}) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        scrollable: true,
        title: Text(title),
        content: SingleChildScrollView(child: Text(content)),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: Text(yesNo ? "Nein" : "Abbrechen"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: Text(yesNo ? "Ja" : "Ok"),
          )
        ],
      );
    },
  );
}
