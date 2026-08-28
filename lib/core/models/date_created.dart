class DateCreated {
  final String dateDb;
  final String monthYear;
  final String timePassed;
  final String timestamp;

  const DateCreated({
    required this.dateDb,
    required this.monthYear,
    required this.timePassed,
    required this.timestamp,
  });

  factory DateCreated.fromJson(Map<String, dynamic> json) {
    return DateCreated(
      dateDb: json['date_db'] as String? ?? '',
      monthYear: json['month_year'] as String? ?? '',
      timePassed: json['time_passed'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? '',
    );
  }
}
