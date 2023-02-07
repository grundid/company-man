import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smallbusiness/reusable/responsive_body.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
        title: Text(AppLocalizations.of(context)!.fehler),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(message),
        ]),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(Localizations.of<MaterialLocalizations>(
                    context, MaterialLocalizations)!
                .okButtonLabel),
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
        title: Text(title),
        content: ResponsiveBody(addPadding: false, child: Text(content)),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(Localizations.of<MaterialLocalizations>(
                    context, MaterialLocalizations)!
                .okButtonLabel),
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
      MaterialLocalizations localizations =
          Localizations.of<MaterialLocalizations>(
              context, MaterialLocalizations)!;
      return AlertDialog(
        scrollable: true,
        title: Text(title),
        content: SingleChildScrollView(child: Text(content)),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: Text(yesNo
                ? AppLocalizations.of(context)!.nein
                : localizations.cancelButtonLabel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: Text(yesNo
                ? AppLocalizations.of(context)!.ja
                : localizations.okButtonLabel),
          )
        ],
      );
    },
  );
}
