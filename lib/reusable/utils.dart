import 'package:flutter/material.dart';

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
