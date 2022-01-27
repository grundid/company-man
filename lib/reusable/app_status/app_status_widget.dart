import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/reusable/app_status/app_status_cubit.dart';
import 'package:smallbusiness/reusable/loader.dart';

class AppStatusWidget extends StatelessWidget {
  final SbmContext sbmContext;
  final Widget child;

  const AppStatusWidget(
      {Key? key, required this.sbmContext, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppStatusCubit>(
      create: (context) => AppStatusCubit(sbmContext),
      child: BlocBuilder<AppStatusCubit, AppStatusState>(
        builder: (context, state) => state is AppStatusInitialized
            ? state.isValid
                ? child
                : state.offline
                    ? Scaffold(
                        body: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Die App kann nicht initialisiert werden, weil keine Internetverbindung aufgebaut werden kann.\n\n"
                              "Bitte prüfen Sie, dass Ihr Gerät eine funktionierende Internetverbindung hat und starten Sie die App erneut.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.red),
                            ),
                            ButtonBar(
                              alignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                    onPressed: () {
                                      context.read<AppStatusCubit>().retry();
                                    },
                                    child: Text("Erneut versuchen"))
                              ],
                            )
                          ],
                        ),
                      )
                    : Scaffold(
                        body: Center(
                          child: Text(
                            "Die App Version ist veraltet.\n[${state.appVersion}]\nBitte aktualisieren Sie die App.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      )
            : LoadingAnimationScaffold(),
      ),
    );
  }
}
