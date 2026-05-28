import 'package:intl/intl.dart';

extension DateTimeExt on DateTime {
  bool get isOverdue => isBefore(DateTime.now());

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  String get deadlineLabel {
    if (isToday) return 'Today';
    if (isTomorrow) return 'Tomorrow';
    if (isOverdue) return DateFormat('MMM d').format(this);
    if (year == DateTime.now().year) return DateFormat('MMM d').format(this);
    return DateFormat('MMM d, y').format(this);
  }

  String get shortFormat => DateFormat('MMM d, y').format(this);

  String get timeAgo {
    final diff = DateTime.now().difference(this);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return shortFormat;
  }
}

extension NullableDateTimeExt on DateTime? {
  String get deadlineLabelOrEmpty => this?.deadlineLabel ?? '';
  bool get isOverdueOrFalse => this?.isOverdue ?? false;
}
