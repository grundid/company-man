import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Über Small Business App"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("Small Business App - Planung und Organisation"),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                          "GrundID GmbH\nHannah-Arendt-Straße. 23\n74831 Gundelsheim"),
                    ),
                  ]),
            ),
            LinkListTile(
                title: "info@grundid.de", url: "mailto:info@grundid.de"),
            LinkListTile(
                title: "Datenschutzerklärung anzeigen",
                url: "https://grundid.de/privacy"),
            LinkListTile(
                title: "AGBs anzeigen",
                url: "https://grundid.de/agb-smallbusiness-beta.html"),
          ],
        ),
      ),
    );
  }
}

class LinkListTile extends StatelessWidget {
  final String title;
  final String url;

  const LinkListTile({
    Key? key,
    required this.title,
    required this.url,
  }) : super(key: key);

  _launchUrl() async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Can not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: _launchUrl,
      title: Text(title),
      trailing: IconButton(
        icon: Icon(Icons.link),
        onPressed: _launchUrl,
      ),
    );
  }
}
