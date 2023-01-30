import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:archive/archive.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:smallbusiness/reusable/formatters.dart';
import 'package:smallbusiness/reusable/model_utils.dart';
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
  summaryFile.add(["Mitarbeiter", "Jahr", "Monat", "Arbeitszeit", "Vergütung"]);
  for (MonthlySummaryPerEmployee perEmployee in monthlySummary.employees) {
    summaryFile.add([
      perEmployee.employee.displayName(),
      monthlySummary.month.year.toString(),
      monthlySummary.month.month.toString(),
      perEmployee.hoursMinutes.toCsv(),
      centToUserOutput(perEmployee.totalWageInCent)!
    ]);
  }
  CsvExportArchive exportArchive = CsvExportArchive();
  exportArchive.addCsvFile(
      "vergütung-mitarbeiter-gesamt-$monthLabel.csv", summaryFile);

  for (MonthlySummaryPerEmployee perEmployee in monthlySummary.employees) {
    List<List<String>> employeeFile =
        createEmployeeExport(perEmployee.timeRecordings);
    exportArchive.addCsvFile(
        "${perEmployee.employee.displayName().toLowerCase()}-$monthLabel.csv",
        employeeFile);
  }

  return ShareableContent("arbeitszeiten-export-$monthLabel.zip".toLowerCase(),
      exportArchive.getEncodedZip());
}

List<List<String>> createEmployeeExport(
    Iterable<TimeRecordingWithWage> timeRecordings) {
  DateFormat fullDateFormat = DateFormat.yMMMd().add_Hms();
  DateFormat dateFormat = DateFormat.yMMMEd();
  DateFormat hourFormat = DateFormat.Hm();

  List<List<String>> employeeFile = [];
  employeeFile.add([
    "Datum",
    "Von",
    "Bis",
    "Arbeitszeit",
    "Pause",
    "Pausezeiten",
    "Stundensatz",
    "Vergütung",
    "Erfassung begonnen",
    "Erfassung beendet"
  ]);
  for (TimeRecordingWithWage timeRecordingWithWage in timeRecordings) {
    TimeRecordingHolder timeRecording = timeRecordingWithWage.timeRecording;
    if (timeRecording.to != null) {
      HoursMinutes duration =
          HoursMinutes.fromDuration(timeRecording.duration!);
      HoursMinutes pauseDuration =
          HoursMinutes.fromDuration(timeRecording.pauseDuration);
      employeeFile.add([
        dateFormat.format(timeRecording.from),
        hourFormat.format(timeRecording.from),
        hourFormat.format(timeRecording.to!),
        duration.toCsv(),
        pauseDuration.toCsv(),
        timeRecording.pauses
            .map((pause) =>
                "${hourFormat.format(pause.from)}-${hourFormat.format(pause.to)}")
            .join(", "),
        timeRecordingWithWage.wage != null
            ? centToUserOutput(timeRecordingWithWage.wage!.wageInCent)!
            : "",
        timeRecordingWithWage.wage != null
            ? centToUserOutput(
                calculateWage(duration, timeRecordingWithWage.wage!))!
            : "",
        fullDateFormat.format(timeRecording.created),
        timeRecording.finalizedDate != null
            ? fullDateFormat.format(timeRecording.finalizedDate!)
            : ""
      ]);
    }
  }
  return employeeFile;
}
