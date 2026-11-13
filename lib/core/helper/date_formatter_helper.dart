class DateFormatterHelper {
  DateFormatterHelper._();

  /// Formats ISO timestamp strings (e.g. "2026-08-17T12:05:07.000000Z") into clean human readable date/time.
  /// Example output: "17 Aug 2026, 12:05 PM" or "17 Aug 2026"
  static String formatIsoDate(String? isoString, {bool showTime = true}) {
    if (isoString == null || isoString.trim().isEmpty) return '';

    // Return as is if already formatted
    if (!isoString.contains('T') && !isoString.contains('-')) {
      return isoString;
    }

    try {
      final dateTime = DateTime.parse(isoString.trim()).toLocal();
      final now = DateTime.now();

      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];

      final day = dateTime.day;
      final month = months[dateTime.month - 1];
      final year = dateTime.year;

      if (!showTime) {
        return "$day $month $year";
      }

      int hour = dateTime.hour;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      hour = hour % 12;
      if (hour == 0) hour = 12;

      // Check for Today / Yesterday
      if (dateTime.year == now.year &&
          dateTime.month == now.month &&
          dateTime.day == now.day) {
        return "Today, $hour:$minute $period";
      }

      final yesterday = now.subtract(const Duration(days: 1));
      if (dateTime.year == yesterday.year &&
          dateTime.month == yesterday.month &&
          dateTime.day == yesterday.day) {
        return "Yesterday, $hour:$minute $period";
      }

      return "$day $month $year, $hour:$minute $period";
    } catch (_) {
      return isoString;
    }
  }

  /// Formats relative time (e.g. "Just now", "5 mins ago", "2 days ago", or "17 Aug 2026")
  static String formatRelativeOrDate(String? isoString) {
    if (isoString == null || isoString.trim().isEmpty) return '';

    if (!isoString.contains('T') && !isoString.contains('-')) {
      return isoString;
    }

    try {
      final dateTime = DateTime.parse(isoString.trim()).toLocal();
      final difference = DateTime.now().difference(dateTime);

      if (difference.inSeconds < 60) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        final mins = difference.inMinutes;
        return '$mins ${mins == 1 ? 'min' : 'mins'} ago';
      } else if (difference.inHours < 24) {
        final hours = difference.inHours;
        return '$hours ${hours == 1 ? 'hr' : 'hrs'} ago';
      } else if (difference.inDays < 7) {
        final days = difference.inDays;
        return '$days ${days == 1 ? 'day' : 'days'} ago';
      } else {
        return formatIsoDate(isoString, showTime: false);
      }
    } catch (_) {
      return isoString;
    }
  }
}
