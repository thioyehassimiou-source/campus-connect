class Resource {
  final String id;
  final String title;
  final String description;
  final String url;
  final String type; // PDF, VIDEO, LINK
  final String subject;
  final String authorName;
  final String? authorId;
  final DateTime date;
  final String? scope;
  final String? departmentId;
  final String? facultyId;
  final String? niveau;

  Resource({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.type,
    required this.subject,
    required this.authorName,
    this.authorId,
    required this.date,
    this.scope,
    this.departmentId,
    this.facultyId,
    this.niveau,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      type: json['type'] ?? 'PDF',
      subject: json['subject'] ?? '',
      authorName: json['author_name'] ?? 'Enseignant',
      authorId: json['author_id']?.toString(),
      date: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      scope: json['scope'],
      departmentId: json['department_id']?.toString(),
      facultyId: json['faculty_id']?.toString(),
      niveau: json['niveau'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'url': url,
      'type': type,
      'subject': subject,
      'author_id': authorId,
      'author_name': authorName,
      'created_at': date.toIso8601String(),
      'scope': scope,
      'department_id': departmentId,
      'faculty_id': facultyId,
      'niveau': niveau,
    };
  }

  DateTime get uploadDate => date;
}
