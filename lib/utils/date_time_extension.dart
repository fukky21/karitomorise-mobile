extension DateTimeExtension on DateTime {
  /// 例: 2021/03/26 10:00
  String toYMDHHMMString() {
    if (this != null) {
      final year = this.year.toString();
      final month = this.month.toString().padLeft(2, '0');
      final day = this.day.toString().padLeft(2, '0');
      final hour = this.hour.toString().padLeft(2, '0');
      final minute = this.minute.toString().padLeft(2, '0');
      return '$year/$month/$day $hour:$minute';
    }
    return '';
  }

  /// 例: 2021/03/26
  String toYMDString() {
    if (this != null) {
      final year = this.year.toString();
      final month = this.month.toString().padLeft(2, '0');
      final day = this.day.toString().padLeft(2, '0');
      return '$year/$month/$day';
    }
    return '';
  }

  /// 例: 03/26 10:00
  String toMDHHMMString() {
    if (this != null) {
      final month = this.month.toString().padLeft(2, '0');
      final day = this.day.toString().padLeft(2, '0');
      final hour = this.hour.toString().padLeft(2, '0');
      final minute = this.minute.toString().padLeft(2, '0');
      return '$month/$day $hour:$minute';
    }
    return '';
  }

  /// 例: 10:00
  String toHHMMString() {
    if (this != null) {
      final hour = this.hour.toString().padLeft(2, '0');
      final minute = this.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }
    return '';
  }
}
