import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterfire_ui/i10n.dart';
import 'package:form_builder_validators/localization/l10n.dart';
import 'package:intl/intl_standalone.dart';
import 'package:smallbusiness/auth/sign_in_widget.dart';
import 'package:smallbusiness/company/no_roles_card_widget.dart';
import 'package:smallbusiness/reusable/loader.dart';
import 'auth/cubit/auth_cubit.dart';
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        supportedLocales: const [Locale("de")],
        title: "Small Business App",
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          FormBuilderLocalizations.delegate,
        ],
        theme: ThemeData(
          primarySwatch: Colors.teal,
        ),
        debugShowCheckedModeBanner: false,
        home: FirebaseInitWidget());
  }
}

class FirebaseInitWidget extends StatelessWidget {
  const FirebaseInitWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseApp>(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, AsyncSnapshot<FirebaseApp> snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text('Error initializing Firebase\n${snapshot.error}',
                    style: Theme.of(context).textTheme.bodyText1),
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return FirebaseAppWidget(firebaseApp: snapshot.data!);
          } else {
            return LoadingAnimationScaffold();
          }
        });
  }
}

class FirebaseAppWidget extends StatelessWidget {
  final FirebaseApp firebaseApp;

  const FirebaseAppWidget({Key? key, required this.firebaseApp})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: firebaseApp,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
              create: (_) =>
                  AuthCubit(FirebaseAuth.instanceFor(app: firebaseApp))),
        ],
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) => Scaffold(
            appBar: AppBar(
              title: Text("Small Business App"),
            ),
            body: state is AuthInitialized
                ? NoRolesCardWidget(
                    onCreateCompany: () {},
                    onJoinCompany: (inviteId) {},
                  )
                : state is AuthNotLoggedIn
                    ? SignInWidget(
                        onSignIn: () {
                          context.read<AuthCubit>().signIn();
                        },
                      )
                    : LoadingAnimationScreen(
                        delay: Duration.zero,
                      ),
          ),
        ),
      ),
    );
  }
}
