import 'package:flutter/material.dart';
import 'package:flutterfire_ui/i10n.dart';
import 'package:intl/intl_standalone.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  findSystemLocale().then((locale) {
    runApp(const SmallBusinessApp());
  });
}

class SmallBusinessApp extends StatelessWidget {
  const SmallBusinessApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseApp>(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, AsyncSnapshot<FirebaseApp> snapshot) {
          return MaterialApp(
            supportedLocales: const [Locale("de")],
            title: "Small Business App",
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeData(
              primarySwatch: Colors.teal,
            ),
            debugShowCheckedModeBanner: false,
            home: const MyHomePage(title: "Small Business App"),
          );
        });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Text("Willkommen"),
      ),
    );
  }
}
