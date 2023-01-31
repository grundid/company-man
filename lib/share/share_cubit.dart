import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:universal_html/html.dart' as html;

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smallbusiness/share/share_widget.dart';

@immutable
abstract class ShareState {}

class ShareInitialized extends ShareState {
  final ShareableContent shareableContent;

  ShareInitialized(this.shareableContent);
}

class SharePrepared extends ShareState {}

class ShareCubit extends Cubit<ShareState> {
  final ShareableBuilder shareableBuilder;

  ShareCubit(this.shareableBuilder) : super(SharePrepared());

  void share() async {
    ShareableContent? shareableContent = await shareableBuilder();
    if (shareableContent != null) {
      emit(ShareInitialized(shareableContent));
    }
  }
}

String contentTypeForFile(String fileName) => fileName.endsWith("zip")
    ? "application/zip"
    : fileName.endsWith("pdf")
        ? "application/pdf"
        : fileName.endsWith("csv")
            ? "text/csv"
            : "application/binary";

Future<void> shareOrSaveExport(
    BuildContext context, ShareableContent shareableContent) async {
  if (kIsWeb) {
    String contentType = contentTypeForFile(shareableContent.fileName);
    var blob = html.File([shareableContent.data], shareableContent.fileName,
        {'type': contentType});
    var url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement()
      // ignore: unsafe_html
      ..href = url
      ..download = shareableContent.fileName
      ..target = 'blank'
      ..click()
      ..remove();

    html.Url.revokeObjectUrl(url);
  } else {
    final box = context.findRenderObject() as RenderBox?;
    Directory tempDir = await getTemporaryDirectory();
    File shareFile = File("${tempDir.path}/${shareableContent.fileName}");
    shareFile.writeAsBytesSync(shareableContent.data, flush: true);

    List<XFile> files = [
      XFile(
        shareFile.path,
        name: shareableContent.fileName,
        mimeType: contentTypeForFile(shareableContent.fileName),
      )
    ];

    await Share.shareXFiles(files,
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
    shareFile.deleteSync();
  }
}
