import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:universal_html/html.dart' as html;

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smallbusiness/share/share_widget.dart';

part 'share_state.dart';

class ShareCubit extends Cubit<ShareState> {
  final ShareableBuilder shareableBuilder;

  File? shareFile;
  ShareCubit(this.shareableBuilder) : super(ShareInitialized());

  _saveOnWeb(ShareableContent content) {
    String contentType = content.fileName.endsWith("zip")
        ? "application/zip"
        : content.fileName.endsWith("pdf")
            ? "application/pdf"
            : content.fileName.endsWith("csv")
                ? "text/csv"
                : "application/binary";
    var blob =
        html.File([content.data], content.fileName, {'type': contentType});
    var url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement()
      // ignore: unsafe_html
      ..href = url
      ..download = content.fileName
      ..target = 'blank'
      ..click()
      ..remove();

    html.Url.revokeObjectUrl(url);
  }

  _shareExport(ShareableContent content) async {
    _cleanupShareFile();
    Directory tempDir = await getTemporaryDirectory();
    shareFile = File("${tempDir.path}/${content.fileName}");
    shareFile!.writeAsBytesSync(content.data, flush: true);
    await Share.shareFiles([shareFile!.path], text: content.fileName);
  }

  @override
  close() async {
    _cleanupShareFile();
    super.close();
  }

  _cleanupShareFile() {
    if (shareFile != null) {
      try {
        shareFile!.deleteSync();
      } finally {
        shareFile = null;
      }
    }
  }

  void share() async {
    ShareableContent? shareableContent = await shareableBuilder();
    if (shareableContent != null) {
      if (kIsWeb) {
        _saveOnWeb(shareableContent);
      } else if (Platform.isIOS || Platform.isAndroid) {
        _shareExport(shareableContent);
      }
    }
  }
}
