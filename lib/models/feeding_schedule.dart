class FeedingSchedule {
  final String id;
  final DateTime time;
  final double amount;

  FeedingSchedule({
    required this.id,
    required this.time,
    required this.amount,
  });

  factory FeedingSchedule.fromJson(Map<String, dynamic> json) {
    return FeedingSchedule(
      id: json['id']?.toString() ?? '',
      time: DateTime.parse(json['time']),
      amount: json['amount']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': time.toIso8601String(),
      'amount': amount,
    };
  }
}