import 'package:intl/intl.dart';
import 'package:smallbusiness/time_recording/utils.dart';

const String DE_LOCALE = "de_DE";

final DateFormat fileDateFormatter = DateFormat.yMd(DE_LOCALE);
final DateFormat invoiceDateFormatter = DateFormat.yMd();
final DateFormat fullDateFormatter = DateFormat.yMEd(DE_LOCALE);
final DateFormat dateFormatterWithoutYear = DateFormat.MEd();
final DateFormat dateFormatterMonthYear = DateFormat.yMMMM();
final DateFormat hourFormatter = DateFormat.Hm();
final DateFormat dateTimeFormatter = DateFormat.yMEd().add_Hms();
final DateFormat dateTimeFormatterWithoutSeconds =
    DateFormat.yMEd(DE_LOCALE).add_Hm();
final DateFormat dateTimeShortFormatter = DateFormat.MEd().add_Hm();
final fullDayDateFormatter = DateFormat("EEEE',' ").add_yMd();

final NumberFormat doubleZeroFormatter = NumberFormat("00");
final NumberFormat simpleCurrencyFormatter =
    NumberFormat.decimalPattern(DE_LOCALE);
final NumberFormat currencyFormatter =
    NumberFormat.currency(name: "EUR", locale: DE_LOCALE);
final NumberFormat currencyFormatter2Digits =
    NumberFormat.currency(name: "EUR", decimalDigits: 2, locale: DE_LOCALE);
final NumberFormat currencyFormatter2DigitsSymbol =
    NumberFormat.currency(name: "€", decimalDigits: 2, locale: DE_LOCALE);
final NumberFormat currencyFormatterSEPA = NumberFormat("#,##0.00", DE_LOCALE);
final NumberFormat intFormatter = NumberFormat("0");
final NumberFormat cmFormatter = NumberFormat("0.##", DE_LOCALE);
final NumberFormat amountFormatter = NumberFormat("0.##", DE_LOCALE);

int? decimalToCent(num? value) {
  return value == null ? null : (value * 100).round();
}

double? centToDecimal(int? value) {
  return value == null ? null : (value / 100.0);
}

int? userInputToCent(String? formValue) {
  if (formValue != null) {
    try {
      return decimalToCent(simpleCurrencyFormatter.parse(formValue));
    } catch (e) {
      return null;
    }
  }
  return null;
}

/// returns an integer. If formValue is null or empty or cannot be parsed as number NULL is returned.
int? userInputToNumber(String? formValue) {
  if (true == formValue?.isNotEmpty) {
    try {
      return int.parse(formValue!);
    } catch (e) {
      return null;
    }
  }
  return null;
}

double? userInputToAmount(String? formValue) {
  if (true == formValue?.isNotEmpty) {
    try {
      return amountFormatter.parse(formValue!).toDouble();
    } catch (e) {
      return null;
    }
  }
  return null;
}

String? centToUserInput(int? cent) {
  return cent == null
      ? null
      : simpleCurrencyFormatter.format(centToDecimal(cent));
}

String? centToUserOutput(int? cent) {
  return cent == null
      ? null
      : currencyFormatter2Digits.format(centToDecimal(cent));
}

String? numberToUserInput(num? number) {
  return number == null ? null : "$number";
}

class DurationDateTimeLabels {
  final String dateTimeLabel;
  final String timeDurationLabel;
  final String timeLabel;
  final String durationLabel;

  DurationDateTimeLabels(this.dateTimeLabel, this.timeLabel,
      this.timeDurationLabel, this.durationLabel);
}
