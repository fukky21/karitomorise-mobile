/// 例: 2021年03月26日
extension DateTimeExtension on DateTime {
  String toYMDString() {
    if (this != null) {
      final year = this.year.toString();
      final month = this.month.toString().padLeft(2, '0');
      final day = this.day.toString().padLeft(2, '0');
      return '$year年$month月$day日';
    }
    return '';
  }
}
