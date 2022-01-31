import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ProjectIdText extends StatefulWidget {
  const ProjectIdText({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ProjectIdState();
  }
}

class _ProjectIdState extends State<ProjectIdText> {
  String projectId = "";
  String projectVersion = "";
  String buildVersion = "";

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    FirebaseOptions options = Firebase.app().options;
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    projectVersion = packageInfo.version;
    buildVersion = packageInfo.buildNumber;
    setState(() {
      projectId = "${options.projectId} $projectVersion ($buildVersion)";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      projectId,
      style: TextStyle(color: Colors.black12),
    );
  }
}
