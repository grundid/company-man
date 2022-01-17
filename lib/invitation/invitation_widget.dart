import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routemaster/routemaster.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/invitation/invitation_cubit.dart';
import 'package:smallbusiness/reusable/loader.dart';

class InvitationWidget extends StatelessWidget {
  final SbmContext sbmContext;
  final String invitationId;
  const InvitationWidget(
      {Key? key, required this.invitationId, required this.sbmContext})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Einladung annehmen"),
      ),
      body: BlocProvider(
        create: (context) => InvitationCubit(sbmContext, invitationId),
        child: BlocConsumer<InvitationCubit, InvitationState>(
          listener: (context, state) {
            if (state is InvitationDone) {
              Routemaster.of(context).pop();
            }
          },
          builder: (context, state) {
            return state is InvitationInitialized
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Sie haben eine Einladung für ${state.invitation.companyLabel}.\nMöchten Sie die Einladung annehmen?",
                          textAlign: TextAlign.center,
                        ),
                        ButtonBar(
                          alignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                                onPressed: () {
                                  context.read<InvitationCubit>().accept();
                                },
                                child: Text("Annehmen"))
                          ],
                        )
                      ],
                    ),
                  )
                : state is InvitationNotFound
                    ? Center(
                        child: Text("Die Einladungs-ID wurde nicht gefunden"),
                      )
                    : LoadingAnimationScreen();
          },
        ),
      ),
    );
  }
}
