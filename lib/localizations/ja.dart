import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class JapaneseCupertinoLocalizations implements CupertinoLocalizations {
  const JapaneseCupertinoLocalizations();

  static const _shortWeekdays = ['月', '火', '水', '木', '金', '土', '日'];

  @override
  String get alertDialogLabel => '確認';

  @override
  String get anteMeridiemAbbreviation => '午前';

  @override
  String get postMeridiemAbbreviation => '午後';

  @override
  String get copyButtonLabel => 'コピー';

  @override
  String get cutButtonLabel => 'カット';

  @override
  String get pasteButtonLabel => 'ペースト';

  @override
  String get selectAllButtonLabel => 'すべて選択';

  @override
  String get modalBarrierDismissLabel => '拒否';

  @override
  DatePickerDateOrder get datePickerDateOrder => DatePickerDateOrder.ymd;

  @override
  DatePickerDateTimeOrder get datePickerDateTimeOrder =>
      DatePickerDateTimeOrder.date_dayPeriod_time;

  @override
  String datePickerYear(int yearIndex) => '$yearIndex年';

  @override
  String datePickerMonth(int monthIndex) => '$monthIndex月';

  @override
  String datePickerDayOfMonth(int dayIndex) => '$dayIndex日';

  @override
  String datePickerHour(int hour) => hour.toString();

  @override
  String datePickerMinute(int minute) => minute.toString().padLeft(2, '0');

  @override
  String datePickerHourSemanticsLabel(int hour) => '$hour時';

  @override
  String datePickerMinuteSemanticsLabel(int minute) => '$minute分';

  @override
  String datePickerMediumDate(DateTime date) {
    return '${date.month}月 '
        '${date.day.toString().padRight(2)}日 '
        '(${_shortWeekdays[date.weekday - DateTime.monday]})';
  }

  @override
  String tabSemanticsLabel({int tabIndex, int tabCount}) =>
      '$tabIndex/$tabCount';

  @override
  String timerPickerHour(int hour) => hour.toString();

  @override
  String timerPickerMinute(int minute) => minute.toString();

  @override
  String timerPickerSecond(int second) => second.toString();

  @override
  String timerPickerHourLabel(int hour) => '時';

  @override
  String timerPickerMinuteLabel(int minute) => '分';

  @override
  String timerPickerSecondLabel(int second) => '秒';

  @override
  String get todayLabel => '今日';

  static Future<CupertinoLocalizations> load(Locale locale) =>
      SynchronousFuture<CupertinoLocalizations>(
        const JapaneseCupertinoLocalizations(),
      );

  static const LocalizationsDelegate<CupertinoLocalizations> delegate =
      _JapaneseCupertinoLocalizationDelegate();
}

class _JapaneseCupertinoLocalizationDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _JapaneseCupertinoLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ja';

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      JapaneseCupertinoLocalizations.load(locale);

  @override
  bool shouldReload(
          covariant LocalizationsDelegate<CupertinoLocalizations> old) =>
      false;
}
