import 'package:intl/intl.dart';

class DateUtils {
  // 获取月份的第一天
  static DateTime firstDayOfMonth(DateTime month) {
    return DateTime(month.year, month.month, 1);
  }

  // 获取月份的最后一天
  static DateTime lastDayOfMonth(DateTime month) {
    return DateTime(month.year, month.month + 1, 0);
  }

  // 获取一周的第一天（周一）
  static DateTime firstDayOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  // 获取一周的最后一天（周日）
  static DateTime lastDayOfWeek(DateTime date) {
    return date.add(Duration(days: DateTime.daysPerWeek - date.weekday));
  }

  // 格式化日期为中文格式
  static String formatChineseDate(DateTime date) {
    return DateFormat('yyyy年MM月dd日').format(date);
  }

  // 格式化时间为中文格式
  static String formatChineseTime(DateTime date) {
    return DateFormat('HH:mm:ss').format(date);
  }

  // 格式化日期时间为中文格式
  static String formatChineseDateTime(DateTime date) {
    return DateFormat('yyyy年MM月dd日 HH:mm:ss').format(date);
  }

  // 获取相对时间描述（如：今天、昨天、2天前等）
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateDay = DateTime(date.year, date.month, date.day);

    if (dateDay == today) {
      return '今天 ${DateFormat('HH:mm').format(date)}';
    } else if (dateDay == yesterday) {
      return '昨天 ${DateFormat('HH:mm').format(date)}';
    } else {
      final difference = today.difference(dateDay).inDays;
      if (difference < 7) {
        return '$difference天前 ${DateFormat('HH:mm').format(date)}';
      } else {
        return DateFormat('MM/dd HH:mm').format(date);
      }
    }
  }

  // 获取月份名称
  static String getMonthName(DateTime date) {
    return DateFormat('MMMM', 'zh_CN').format(date);
  }

  // 获取星期几名称
  static String getWeekdayName(DateTime date) {
    return DateFormat('EEEE', 'zh_CN').format(date);
  }

  // 检查两个日期是否在同一天
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // 检查两个日期是否在同一周
  static bool isSameWeek(DateTime a, DateTime b) {
    final aStart = firstDayOfWeek(a);
    final bStart = firstDayOfWeek(b);
    return isSameDay(aStart, bStart);
  }

  // 检查两个日期是否在同一月
  static bool isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  // 获取日期范围描述
  static String getDateRangeDescription(DateTime start, DateTime end) {
    if (isSameDay(start, end)) {
      return formatChineseDate(start);
    } else if (isSameMonth(start, end)) {
      return '${start.day}日 - ${end.day}日';
    } else if (start.year == end.year) {
      return '${start.month}月${start.day}日 - ${end.month}月${end.day}日';
    } else {
      return '${start.year}年${start.month}月${start.day}日 - ${end.year}年${end.month}月${end.day}日';
    }
  }

  // 获取年龄
  static int getAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // 获取本月天数
  static int getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  // 获取本月所有日期
  static List<DateTime> getDaysInMonthList(DateTime month) {
    final first = firstDayOfMonth(month);
    final last = lastDayOfMonth(month);
    final days = last.day - first.day + 1;
    return List.generate(days, (i) => DateTime(month.year, month.month, i + 1));
  }
}
