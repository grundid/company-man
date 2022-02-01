import 'package:flutter/material.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/auth/sign_in_widget.dart';
import 'package:smallbusiness/reusable/widgets/about_widget.dart';
import 'package:smallbusiness/reusable/widgets/project_id_widget.dart';

class SbmDrawer extends StatelessWidget {
  final SbmContext sbmContext;
  final Function() onLogout;
  final Function(String phoneNumber) onSignInWithPhoneNumber;

  const SbmDrawer(
      {Key? key,
      required this.sbmContext,
      required this.onLogout,
      required this.onSignInWithPhoneNumber})
      : super(key: key);

  _buildDrawerTile(IconData iconData, String text,
          {onTap, bool expanded = true, bool implemented = true}) =>
      (expanded)
          ? ListTile(
              leading: Padding(
                padding: const EdgeInsets.only(left: 2.0),
                child: Icon(iconData),
              ),
              title: Text(
                text,
                style: implemented
                    ? null
                    : TextStyle(decoration: TextDecoration.lineThrough),
              ),
              onTap: onTap,
            )
          : Tooltip(
              message: text,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: IconButton(
                  icon: Icon(
                    iconData,
                    color: Colors.black45,
                  ),
                  onPressed: onTap,
                ),
              ),
            );

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        top: true,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: UserProfileWidget(
                  sbmContext: sbmContext,
                ),
              ),
              /*_buildDrawerTile(Icons.notifications, "Benachrichtigungen",
                  onTap: () {
                _pushUserContextRoute(
                    context,
                    () => NotificationsViewWidget(
                          appContext: appContext,
                        ));
              }),*/
              Divider(),
/*              _buildDrawerTile(Icons.person, "Profil", onTap: () {
                _pushUserContextRoute(
                    context,
                    () => ProfileMenuWidget(
                          appContext: appContext,
                        ));
              }),*/
              _buildDrawerTile(
                Icons.info,
                "Über die App",
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => AboutWidget()));
                },
              ),
              if (sbmContext.user.isAnonymous)
                _buildDrawerTile(
                  Icons.admin_panel_settings_outlined,
                  "Konto verknüpfen",
                  onTap: () async {
                    Navigator.pop(context);
                    String? phoneNumber = await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Konto verknüpfen"),
                          content: PhoneQueryFormWidget(
                            buttonLabel: "Verknüpfen",
                            introduction:
                                "Bitte geben Sie Ihre Telefonnummer ein um Ihr Konto zu verknüpfen.",
                            onSignInWithPhoneNumber: (phoneNumber) {
                              Navigator.pop(context, phoneNumber);
                            },
                            onCancel: () {
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    );
                    if (phoneNumber != null) {
                      onSignInWithPhoneNumber(phoneNumber);
                    }
                  },
                ),
              _buildDrawerTile(
                Icons.input,
                "Ausloggen",
                onTap: () {
                  Navigator.pop(context);
                  onLogout();
                },
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(child: ProjectIdText()),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class UserProfileWidget extends StatelessWidget {
  const UserProfileWidget({
    Key? key,
    required this.sbmContext,
  }) : super(key: key);

  final SbmContext sbmContext;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sbmContext.user.displayName ?? "Anonym",
          style: Theme.of(context).textTheme.headline6,
        ),
        Text(
          sbmContext.user.companyLabel ?? "Ohne Firma",
          style: Theme.of(context).textTheme.subtitle2,
        ),
        Text(
          sbmContext.user.isAnonymous
              ? "Ohne Kontoverknüpfung"
              : "${sbmContext.user.user.phoneNumber}",
          style: Theme.of(context).textTheme.subtitle2,
        ),
      ],
    );
  }
}
