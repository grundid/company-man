import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:form_builder_validators/localization/l10n.dart';
import 'package:routemaster/routemaster.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/auth/drawer_widget.dart';
import 'package:smallbusiness/auth/phone_signin_widget.dart';
import 'package:smallbusiness/auth/sign_in_widget.dart';
import 'package:smallbusiness/company/company_edit_widget.dart';
import 'package:smallbusiness/company/company_main_widget.dart';
import 'package:smallbusiness/company/employee/employee_user_widget.dart';
import 'package:smallbusiness/company/employee_edit_widget.dart';
import 'package:smallbusiness/company/employee_list_widget.dart';
import 'package:smallbusiness/company/employee_menu_widget.dart';
import 'package:smallbusiness/company/no_roles_card_widget.dart';
import 'package:smallbusiness/invitation/invitation_widget.dart';
import 'package:smallbusiness/reusable/app_status/app_status_widget.dart';
import 'package:smallbusiness/reusable/loader.dart';
import 'package:smallbusiness/reusable/query_builder.dart';
import 'package:smallbusiness/reusable/responsive_body.dart';
import 'package:smallbusiness/reusable/utils.dart';
import 'package:smallbusiness/time_recording/time_recording_list_employee_widget.dart';
import 'package:smallbusiness/time_recording/time_recording_list_widget.dart';
import 'package:smallbusiness/time_recording/time_recording_widget.dart';
import 'auth/cubit/auth_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

const String appTitle = "Small Business App";

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  findSystemLocale().then((_) {
    runApp(ChangeNotifierProvider<SbmContext>(
      create: (context) => SbmContext(),
      child: const SmallBusinessApp(),
    ));
  });
}

class RouteNames {
  static String companyEdit = "/company/edit";
  static String employeeEdit = "/employee/edit";
  static String employeeList = "/employee/list";
  static String employeeMenu = "/employee/menu";
  static String employeeUser = "/employee/user";
  static String invitation = "/invitation";
  static String timeRecording = "/timeRecording";
  static String timeRecordingList = "/timeRecordingList";
  static String timeRecordingListEmployee = "/timeRecordingListEmployee";
  static String timeRecordingListEdit = "/timeRecordingList/edit";
  static String signInWithPhoneNumber = "/signInWithPhoneNumber";
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
          RouteNames.companyEdit: (RouteData routeData) => MaterialPage(
                  child: CompanyEditWidget(
                companyId: routeData.queryParameters["id"],
              )),
          RouteNames.employeeList: (RouteData routeData) =>
              MaterialPage(child: EmployeeListWidget()),
          RouteNames.employeeMenu: (RouteData routeData) => MaterialPage(
                child: EmployeeMenuWidget(
                  employeeId: routeData.queryParameters["employeeId"]!,
                ),
              ),
          RouteNames.employeeEdit: (RouteData routeData) => MaterialPage(
                child: EmployeeEditWidget(
                  employeeId: routeData.queryParameters["employeeId"],
                ),
              ),
          RouteNames.employeeUser: (RouteData routeData) => MaterialPage(
                child: EmployeeUserWidget(
                  employeeId: routeData.queryParameters["employeeId"]!,
                ),
              ),
          RouteNames.invitation: (RouteData routeData) => MaterialPage(
                child: InvitationWidget(
                  sbmContext: Provider.of<SbmContext>(context, listen: false),
                  invitationId: routeData.queryParameters["invitationId"]!,
                ),
              ),
          RouteNames.timeRecording: (RouteData routeData) => MaterialPage(
                child: TimeRecordingWidget(
                  sbmContext: Provider.of<SbmContext>(context, listen: false),
                ),
              ),
          RouteNames.timeRecordingList: (RouteData routeData) => MaterialPage(
                child: TimeRecordingListWidget(
                  sbmContext: Provider.of<SbmContext>(context, listen: false),
                ),
              ),
          RouteNames.timeRecordingListEmployee: (RouteData routeData) =>
              MaterialPage(
                child: TimeRecordingListEmployeeWidget(
                  sbmContext: Provider.of<SbmContext>(context, listen: false),
                ),
              ),
          RouteNames.timeRecordingListEdit: (RouteData routeData) =>
              MaterialPage(
                child: TimeRecordingWidget(
                  sbmContext: Provider.of<SbmContext>(context, listen: false),
                  timeRecordingId: routeData.queryParameters["timeRecordingId"],
                ),
              ),
          RouteNames.signInWithPhoneNumber: (RouteData routeData) =>
              MaterialPage(
                child: PhoneSignInWidget(
                  sbmContext: Provider.of<SbmContext>(context, listen: false),
                  phoneNumber: routeData.queryParameters["phoneNumber"]!,
                ),
              ),
        }),
      ),
      routeInformationParser: RoutemasterParser(),
      supportedLocales: [Locale("de")],
      locale: Locale("de"),
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
      drawer: SbmDrawer(
        sbmContext: sbmContext,
        onLogout: () async {
          if (sbmContext.user.isAnonymous) {
            bool? result = await showQueryDialog(context, "Anonymer Account",
                "Sie verwenden einen anonymen Account. Wenn Sie sich jetzt ausloggen, gehen all Ihre Daten verloren.");
            if (true == result) {
              context.read<AuthCubit>().signOut();
            }
          } else {
            context.read<AuthCubit>().signOut();
          }
        },
        onSignInWithPhoneNumber: (phoneNumber) {
          Routemaster.of(context).push(RouteNames.signInWithPhoneNumber +
              "?phoneNumber=${Uri.encodeComponent(phoneNumber)}");
        },
      ),
      body: sbmContext.user.hasCompany
          ? ResponsiveBody(
              addPadding: false,
              child: CompanyMainWidget(sbmContext: sbmContext))
          : ResponsiveBody(
              addPadding: false,
              child: NoRolesCardWidget(
                onCreateCompany: () {
                  Routemaster.of(context).push(RouteNames.companyEdit);
                },
                onJoinCompany: (inviteId) async {
                  bool? result = await Routemaster.of(context)
                      .push<bool>(
                          RouteNames.invitation + "?invitationId=$inviteId")
                      .result;
                  if (true == result) {
                    context.read<AuthCubit>().updateUser();
                  }
                },
              ),
            ),
    );
  }
}

class FirebaseInitWidget extends StatelessWidget {
  const FirebaseInitWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseApp>(
        future: Firebase.initializeApp(),
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
            SbmContext sbmContext =
                Provider.of<SbmContext>(context, listen: false);
            FirebaseFirestore firestore = FirebaseFirestore.instance;
            sbmContext.initFirestore(QueryBuilder(firestore: firestore));

            return AppStatusWidget(
              sbmContext: sbmContext,
              child: BlocProvider(
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
                          onSignInWithPhoneNumber: (phoneNumber) {
                            Routemaster.of(context).push(RouteNames
                                    .signInWithPhoneNumber +
                                "?phoneNumber=${Uri.encodeComponent(phoneNumber)}");
                          },
                        ),
                      );
                    } else {
                      return LoadingAnimationScaffold();
                    }
                  },
                ),
              ),
            );
          } else {
            return LoadingAnimationScaffold();
          }
        });
  }
}
