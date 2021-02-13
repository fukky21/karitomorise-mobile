/// 例: 2021年03月26日
String getYMDString(DateTime dateTime) {
  if (dateTime != null) {
    final year = dateTime.year.toString();
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    return '$year年$month月$day日';
  }
  return '';
}
