class Document {
  final String id;
  final String title;
  final String? description;
  final String? fileUrl;
  final String uploadedBy;
  final TypeDocument type;
  final DateTime uploadedAt;
  final List<String>? tags;

  Document({
    required this.id,
    required this.title,
    this.description,
    this.fileUrl,
    required this.uploadedBy,
    required this.type,
    required this.uploadedAt,
    this.tags,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      fileUrl: json['file_url'],
      uploadedBy: json['uploaded_by'] ?? '',
      type: _parseType(json['type']),
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.parse(json['uploaded_at'])
          : DateTime.now(),
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
    );
  }

  static TypeDocument _parseType(dynamic typeValue) {
    if (typeValue == null) return TypeDocument.other;
    final typeStr = typeValue.toString().toLowerCase();
    if (typeStr.contains('pdf')) return TypeDocument.pdf;
    if (typeStr.contains('image')) return TypeDocument.image;
    if (typeStr.contains('video')) return TypeDocument.video;
    if (typeStr.contains('word')) return TypeDocument.word;
    return TypeDocument.other;
  }
}

enum TypeDocument {
  pdf,
  image,
  video,
  word,
  other,
}
