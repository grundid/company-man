import 'package:flutter/material.dart';

class SingleColumnBody extends StatelessWidget {
  final List<Widget> children;

  const SingleColumnBody({Key? key, required this.children}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 450,
          minWidth: 300,
          maxHeight: double.infinity,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: children,
          ),
        ),
      ),
    );
  }
}

class ResponsiveBody extends StatelessWidget {
  final Widget child;
  final bool addPadding;

  const ResponsiveBody({Key? key, required this.child, this.addPadding = true})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: addPadding
          ? EdgeInsets.symmetric(horizontal: 16, vertical: 16)
          : null,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 650,
            minWidth: 300,
            maxHeight: double.infinity,
          ),
          child: child,
        ),
      ),
    );
  }
}

class ResponsiveListViewElement extends StatelessWidget {
  final Widget child;

  const ResponsiveListViewElement({Key? key, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 650,
          minWidth: 300,
          maxHeight: double.infinity,
        ),
        child: child,
      ),
    );
  }
}
