const List<String> monthsList = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'
];

List<String> getYearsList() {
  final currentYear = DateTime.now().year;
  return [
    '${currentYear - 2}',
    '${currentYear - 1}',
    '$currentYear',
    '${currentYear + 1}',
    '${currentYear + 2}'
  ];
}
