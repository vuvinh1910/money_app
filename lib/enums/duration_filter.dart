import 'package:jiffy/jiffy.dart';

class DurationFilter {
  final int _value;
  final String _name;

  const DurationFilter._internal(this._value, this._name);

  static const TODAY = const DurationFilter._internal(0, 'Hôm nay');
  static const THISWEEK = const DurationFilter._internal(1, 'Tuần này');
  static const THISMONTH = const DurationFilter._internal(1, 'Tháng này');
  static const THISYEAR = const DurationFilter._internal(1, 'Năm nay');

  int get value => _value;

  String get name => _name;

  static getAllType() {
    return [DurationFilter.TODAY._name, DurationFilter.THISWEEK._name, DurationFilter.THISMONTH.name, DurationFilter.THISYEAR.name];
  }

  static DurationFilter ?valueOf(int value) {
    switch (value) {
      case 0:
        return TODAY;
      case 1:
        return THISWEEK;
      case 2:
        return THISMONTH;
      case 3:
        return THISYEAR;
      default:
        return null;
    }
  }

  static DurationFilter ?valueFromName(String name) {
    switch (name) {
      case 'Hôm nay':
        return TODAY;
      case 'Tuần này':
        return THISWEEK;
      case 'Tháng này':
        return THISMONTH;
      case 'Năm nay':
        return THISYEAR;
      default:
        return null;
    }
  }

  static bool checkValidInDurationFromNow(DateTime date, DurationFilter filter) {
    DateTime now = DateTime.now();

    if (filter == DurationFilter.TODAY) {
      return (date.day == now.day && date.month == now.month && date.year == now.year);
    }
    else if (filter == DurationFilter.THISWEEK) {
      // Get the start of the week (Monday)
      DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      startOfWeek = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

      // Get the end of the week (Sunday)
      DateTime endOfWeek = startOfWeek.add(Duration(days: 6));
      endOfWeek = DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59);

      // Check if date is within the current week
      return date.isAfter(startOfWeek.subtract(Duration(seconds: 1))) &&
          date.isBefore(endOfWeek.add(Duration(seconds: 1)));
    }
    else if (filter == DurationFilter.THISMONTH) {
      return date.month == now.month && date.year == now.year;
    }
    else if (filter == DurationFilter.THISYEAR) {
      return date.year == now.year;
    }
    return false;
  }
}
