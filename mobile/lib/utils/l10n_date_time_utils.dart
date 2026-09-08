class L10nDateTimeUtils {
  static String timeAgo(DateTime dateTime) {
    final Duration difference = DateTime.now().difference(dateTime);

    if (difference.inSeconds < 60) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} 分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} 小时前';
    } else if (difference.inDays < 10) {
      return '${difference.inDays} 天前';
    } else {
      return '${dateTime.month}月${dateTime.day}日';
    }
  }

  static String toStringLocal(DateTime dateTime) {
    dateTime = dateTime.toLocal();
    final timeString =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    return '${dateTime.year}年${dateTime.month}月${dateTime.day}日 $timeString';
  }
}
