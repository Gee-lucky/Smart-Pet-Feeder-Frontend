class FeedingSchedule {
  final String id;
  final DateTime date;
  final double portion;

  FeedingSchedule({
    required this.id,
    required this.date,
    required this.portion,
  });

  factory FeedingSchedule.fromJson(Map<String, dynamic> json) {
    return FeedingSchedule(
      id: json['id'].toString(),
      date: DateTime.parse(json['date']),
      portion: double.parse(json['portion'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'portion': portion,
    };
  }
}
