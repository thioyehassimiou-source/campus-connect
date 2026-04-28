class EmploiDuTempsItem {
  final String id;
  final String filiere;
  final String course;
  final String teacher;
  final String room;
  final DateTime startAt;
  final DateTime endAt;

  const EmploiDuTempsItem({
    required this.id,
    required this.filiere,
    required this.course,
    required this.teacher,
    required this.room,
    required this.startAt,
    required this.endAt,
  });

  DateTime get day => DateTime(startAt.year, startAt.month, startAt.day);

  factory EmploiDuTempsItem.fromMap(Map<String, dynamic> map) {
    final id = (map['id'] ?? '').toString();
    final filiere = (map['filiere'] ?? '').toString();
    final course = (map['cours'] ?? map['course'] ?? map['matiere'] ?? '').toString();
    final teacher = (map['enseignant'] ?? map['teacher'] ?? '').toString();
    final room = (map['salle'] ?? map['room'] ?? '').toString();

    final startAt = _parseDateTime(
      date: map['date'] ?? map['jour'] ?? map['day'],
      time: map['heure_debut'] ?? map['start_time'] ?? map['debut'],
      fallback: map['start_at'] ?? map['startAt'],
    );

    final endAt = _parseDateTime(
      date: map['date'] ?? map['jour'] ?? map['day'],
      time: map['heure_fin'] ?? map['end_time'] ?? map['fin'],
      fallback: map['end_at'] ?? map['endAt'],
    );

    return EmploiDuTempsItem(
      id: id,
      filiere: filiere,
      course: course,
      teacher: teacher,
      room: room,
      startAt: startAt,
      endAt: endAt,
    );
  }
}

DateTime _parseDateTime({
  required dynamic date,
  required dynamic time,
  required dynamic fallback,
}) {
  final fromFallback = _tryParseDateTimeValue(fallback);
  if (fromFallback != null) return fromFallback;

  final dateOnly = _tryParseDateValue(date) ?? DateTime.now();
  final hm = _tryParseTimeValue(time);

  if (hm == null) {
    return DateTime(dateOnly.year, dateOnly.month, dateOnly.day);
  }

  return DateTime(
    dateOnly.year,
    dateOnly.month,
    dateOnly.day,
    hm.$1,
    hm.$2,
  );
}

DateTime? _tryParseDateTimeValue(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  if (v is String) {
    return DateTime.tryParse(v);
  }
  return null;
}

DateTime? _tryParseDateValue(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) {
    return DateTime(v.year, v.month, v.day);
  }
  if (v is String) {
    final parsed = DateTime.tryParse(v);
    if (parsed != null) {
      return DateTime(parsed.year, parsed.month, parsed.day);
    }
  }
  return null;
}

({int, int})? _tryParseTimeValue(dynamic v) {
  if (v == null) return null;
  if (v is String) {
    final parts = v.split(':');
    if (parts.length >= 2) {
      final h = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      if (h != null && m != null) return (h, m);
    }
  }
  return null;
}
