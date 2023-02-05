import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routemaster/routemaster.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/invitation/invitation_cubit.dart';
import 'package:smallbusiness/reusable/loader.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
        title: Text(AppLocalizations.of(context)!.einladungAnnehmen),
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
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.of(context)!
                                .sieHabenEineEinladungVonCompanyLabelErhalten(
                                    state.invitation.companyLabel),
                            textAlign: TextAlign.center,
                          ),
                          ButtonBar(
                            alignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                  onPressed: () {
                                    context.read<InvitationCubit>().accept();
                                  },
                                  child: Text(
                                      AppLocalizations.of(context)!.annehmen))
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                : state is InvitationNotFound
                    ? Center(
                        child: Text(AppLocalizations.of(context)!
                            .dieEinladungsIdWurdeNichtGefunden(
                                state.enteredInvitationId)),
                      )
                    : LoadingAnimationScreen();
          },
        ),
      ),
    );
  }
}
