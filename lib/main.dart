import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterfire_ui/i10n.dart';
import 'package:form_builder_validators/localization/l10n.dart';
import 'package:intl/intl_standalone.dart';
import 'package:routemaster/routemaster.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/auth/sign_in_widget.dart';
import 'package:smallbusiness/company/company_edit_widget.dart';
import 'package:smallbusiness/company/company_main_widget.dart';
import 'package:smallbusiness/company/employee_edit_widget.dart';
import 'package:smallbusiness/company/employee_list_widget.dart';
import 'package:smallbusiness/company/employee_menu_widget.dart';
import 'package:smallbusiness/company/no_roles_card_widget.dart';
import 'package:smallbusiness/reusable/loader.dart';
import 'auth/cubit/auth_cubit.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

const String appTitle = "Small Business App";
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  findSystemLocale().then((locale) {
    runApp(ChangeNotifierProvider<SbmContext>(
      create: (context) => SbmContext(),
      child: const SmallBusinessApp(),
    ));
  });
}

class SmallBusinessApp extends StatelessWidget {
  const SmallBusinessApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: RoutemasterDelegate(
        routesBuilder: (context) => RouteMap(routes: {
          "/": (RouteData routeData) =>
              MaterialPage(child: FirebaseInitWidget()),
          "/company/edit": (RouteData routeData) => MaterialPage(
                  child: CompanyEditWidget(
                companyId: routeData.queryParameters["id"],
              )),
          "/employeeList": (RouteData routeData) =>
              MaterialPage(child: EmployeeListWidget()),
          "/employeeList/employeeMenu": (RouteData routeData) => MaterialPage(
                child: EmployeeMenuWidget(
                  employeeId: routeData.queryParameters["employeeId"]!,
                ),
              ),
          "/employeeList/employeeMenu/employeeEdit": (RouteData routeData) =>
              MaterialPage(
                child: EmployeeEditWidget(
                  employeeId: routeData.queryParameters["employeeId"],
                ),
              ),
          "/employeeList/employeeEdit": (RouteData routeData) => MaterialPage(
                child: EmployeeEditWidget(),
              ),
        }),
      ),
      routeInformationParser: RoutemasterParser(),
      supportedLocales: const [Locale("de")],
      title: appTitle,
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
    );
  }
}

class MainWidget extends StatelessWidget {
  final SbmContext sbmContext;

  const MainWidget({Key? key, required this.sbmContext}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appTitle),
      ),
      body: sbmContext.user.hasCompany
          ? CompanyMainWidget(sbmContext: sbmContext)
          : NoRolesCardWidget(
              onCreateCompany: () {
                Routemaster.of(context).push("/company/edit");
              },
              onJoinCompany: (inviteId) {},
            ),
    );
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
            return BlocProvider(
              create: (context) => AuthCubit(
                  Provider.of<SbmContext>(context, listen: false),
                  FirebaseAuth.instanceFor(app: snapshot.data!)),
              child: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  if (state is AuthInitialized) {
                    return MainWidget(
                      sbmContext: state.sbmContext,
                    );
                  } else if (state is AuthNotLoggedIn) {
                    return Scaffold(
                      appBar: AppBar(
                        title: Text(appTitle),
                      ),
                      body: SignInWidget(
                        onSignIn: () {
                          context.read<AuthCubit>().signIn();
                        },
                      ),
                    );
                  } else {
                    return LoadingAnimationScaffold();
                  }
                },
              ),
            );
          } else {
            return LoadingAnimationScaffold();
          }
        });
  }
}
