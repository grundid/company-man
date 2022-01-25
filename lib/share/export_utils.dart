import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:archive/archive.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:smallbusiness/share/share_widget.dart';
import 'package:smallbusiness/time_recording/models.dart';
import 'package:smallbusiness/time_recording/time_recording_list_employee_cubit.dart';
import 'package:smallbusiness/time_recording/utils.dart';

const String defaultSeparator = ";";

String filterFilenameForZip(String fileName) {
  return fileName.replaceAll("/", "_");
}

class CsvExportArchive extends ExportArchive {
  late ListToCsvConverter _listToCsvConverter;

  CsvExportArchive({String separator = defaultSeparator, Encoding? encoding})
      : super(encoding ?? Latin1Codec()) {
    _listToCsvConverter = ListToCsvConverter(fieldDelimiter: separator);
  }

  addCsvFile(String fileName, List<List<dynamic>> lines, {String? folder}) {
    String csvContent = _listToCsvConverter.convert(lines);
    addStringFile(fileName, csvContent, folder: folder);
  }
}

String prepareCleanLatin1Output(String input) {
  StringBuffer result = StringBuffer();
  for (var i = 0; i < input.length; i++) {
    var codeUnit = input.codeUnitAt(i);
    if ((codeUnit & ~0xFF) != 0) {
      result.write("?");
    } else {
      result.writeCharCode(codeUnit);
    }
  }
  return result.toString();
}

class ExportArchive {
  final Archive _archive = Archive();
  final ZipEncoder _encoder = ZipEncoder();
  final Encoding encoding;

  ExportArchive(this.encoding);

  addStringFile(String fileName, String content, {String? folder}) {
    try {
      if (encoding.name == Latin1Codec().name) {
        content = prepareCleanLatin1Output(content);
      }
      List<int> data = encoding.encode(content);
      addFile(fileName, data, folder: folder);
    } catch (e) {
      log(e.toString());
      for (var i = 0; i < content.length; i++) {
        var codeUnit = content.codeUnitAt(i);
        if ((codeUnit & ~0xFF) != 0) {
          log("invalid character [$codeUnit] at position $i (${content.substring(math.max(i - 200, 0), math.min(i + 200, content.length))})");
        }
      }
      rethrow;
    }
  }

  addFile(String fileName, List<int> data, {String? folder}) {
    _archive.addFile(ArchiveFile(
        (folder != null ? filterFilenameForZip(folder) + "/" : "") +
            filterFilenameForZip(fileName),
        data.length,
        data));
  }

  List<int> getEncodedZip() {
    return _encoder.encode(_archive)!;
  }
}

ShareableContent? exportMonthlySummary(MonthlySummary monthlySummary) {
  String monthLabel = monthYearFormatter
      .format(monthlySummary.month)
      .toLowerCase()
      .replaceAll(" ", "-");
  List<List<String>> summaryFile = [];
  summaryFile.add(["Mitarbeiter", "Jahr", "Monat", "Arbeitszeit"]);
  for (MonthlySummaryPerEmployee perEmployee in monthlySummary.employees) {
    summaryFile.add([
      perEmployee.employee.displayName(),
      monthlySummary.month.year.toString(),
      monthlySummary.month.month.toString(),
      perEmployee.hoursMinutes.toCsv()
    ]);
  }
  CsvExportArchive exportArchive = CsvExportArchive();
  exportArchive.addCsvFile(
      "vergütung-mitarbeiter-gesamt-$monthLabel.csv", summaryFile);

  DateFormat fullDateFormat = DateFormat.yMMMd().add_Hms();
  DateFormat dateFormat = DateFormat.yMMMEd();
  DateFormat hourFormat = DateFormat.Hm();
  for (MonthlySummaryPerEmployee perEmployee in monthlySummary.employees) {
    List<List<String>> employeeFile = [];
    employeeFile.add([
      "Datum",
      "Von",
      "Bis",
      "Arbeitszeit",
      "Pause",
      "Erfassung begonnen",
      "Erfassung beendet"
    ]);
    for (TimeRecording timeRecording in perEmployee.timeRecordings) {
      if (timeRecording.to != null) {
        Duration duration = timeRecording.duration()!;
        employeeFile.add([
          dateFormat.format(timeRecording.from),
          hourFormat.format(timeRecording.from),
          hourFormat.format(timeRecording.to!),
          HoursMinutes.fromDuration(duration).toCsv(),
          "",
          fullDateFormat.format(timeRecording.created),
          timeRecording.finalizedDate != null
              ? fullDateFormat.format(timeRecording.finalizedDate!)
              : ""
        ]);
      }
    }
    exportArchive.addCsvFile(
        "${perEmployee.employee.displayName().toLowerCase()}-$monthLabel.csv",
        employeeFile);
  }

  return ShareableContent("arbeitszeiten-export-$monthLabel.csv".toLowerCase(),
      exportArchive.getEncodedZip());
}
