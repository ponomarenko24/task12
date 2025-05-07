class Habit {
  final String id;
  final String name;
  final String frequency;
  final String startDate;
  final Map<String, bool> progress;
  final String userId;

  Habit({
    required this.id,
    required this.name,
    required this.frequency,
    required this.startDate,
    required this.progress,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'frequency': frequency,
      'startDate': startDate,
      'progress': progress,
      'userId': userId,
    };
  }

  static Habit fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'],
      name: map['name'],
      frequency: map['frequency'],
      startDate: map['startDate'],
      progress: Map<String, bool>.from(map['progress'] ?? {}),
      userId: map['userId'],
    );
  }
}
