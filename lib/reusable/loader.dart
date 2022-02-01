import 'dart:async';

import 'package:smallbusiness/reusable/error_handling.dart';

import 'responsive_body.dart';
import 'package:flutter/material.dart';

class LoadingAnimationScaffold extends StatelessWidget {
  final String? titleText;
  final Duration? timeout;

  const LoadingAnimationScaffold({Key? key, this.titleText = "", this.timeout})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: titleText != null
            ? AppBar(
                title: Text(titleText!),
              )
            : null,
        body: LoadingAnimationScreen(
          timeout: timeout,
        ),
      );
}

class LoadingAnimationScreen extends StatefulWidget {
  final Duration? delay;
  final Duration? timeout;
  final String? displayText;
  final dynamic state;

  const LoadingAnimationScreen(
      {Key? key, this.delay, this.timeout, this.displayText, this.state})
      : super(key: key);

  @override
  _LoadingAnimationScreenState createState() => _LoadingAnimationScreenState();
}

class _LoadingAnimationScreenState extends State<LoadingAnimationScreen> {
  bool loading = false;
  bool timeout = false;
  Timer? timeoutTimer;

  @override
  void initState() {
    Timer(widget.delay ?? Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          loading = true;
        });
      }
    });
    _setTimeoutTimer();
    super.initState();
  }

  void _setTimeoutTimer() {
    timeoutTimer = Timer(widget.timeout ?? Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          timeout = true;
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant LoadingAnimationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget != widget) {
      if (true == timeoutTimer?.isActive) {
        timeoutTimer?.cancel();
      }
      timeout = false;
      _setTimeoutTimer();
    }
  }

  @override
  Widget build(BuildContext context) =>
      widget.state != null && widget.state is ErrorHolder
          ? SingleColumnBody(children: [
              Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  widget.state.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red),
                ),
              )
            ])
          : loading
              ? timeout
                  ? SingleColumnBody(children: [
                      Center(
                        child: Text(
                          "Timeout Fehler.\nBitte informieren Sie den Entwickler über das Problem.",
                          textAlign: TextAlign.center,
                        ),
                      )
                    ])
                  : SingleColumnBody(children: [
                      CircularProgressIndicator(),
                      if (widget.displayText != null)
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(widget.displayText!),
                        )
                    ])
              : Container();
}

class ProgressAnimationScreen extends StatelessWidget {
  /// progress in decimal 0.0 - 1.0
  final double progressDouble;
  final String? progressLabel;
  final double horizontalPadding;

  const ProgressAnimationScreen(
      {Key? key,
      required this.progressDouble,
      this.progressLabel,
      this.horizontalPadding = 64})
      : super(key: key);

  @override
  Widget build(BuildContext context) => SingleColumnBody(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: LinearProgressIndicator(
              value: progressDouble,
            ),
          ),
          if (progressLabel != null)
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding, vertical: 16),
              child: Text(
                progressLabel!,
                textAlign: TextAlign.center,
              ),
            )
        ],
      );
}
