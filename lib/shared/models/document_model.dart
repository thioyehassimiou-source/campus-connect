import 'package:equatable/equatable.dart';

enum DocumentType { course, tutorial, lab, exam, resource, other }

enum DocumentTarget { all, students, teachers, specific }

class DocumentModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String fileName;
  final String fileUrl;
  final int fileSize;
  final String fileType;
  final String courseId;
  final String courseName;
  final String teacherId;
  final String teacherName;
  final DocumentType type;
  final DocumentTarget target;
  final List<String> targetUserIds;
  final DateTime uploadDate;
  final DateTime? lastModified;
  final int downloadCount;
  final bool isActive;

  const DocumentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.fileName,
    required this.fileUrl,
    required this.fileSize,
    required this.fileType,
    required this.courseId,
    required this.courseName,
    required this.teacherId,
    required this.teacherName,
    required this.type,
    required this.target,
    required this.targetUserIds,
    required this.uploadDate,
    this.lastModified,
    required this.downloadCount,
    required this.isActive,
  });

  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    return DocumentModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      fileName: map['fileName'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      fileSize: map['fileSize'] ?? 0,
      fileType: map['fileType'] ?? '',
      courseId: map['courseId'] ?? '',
      courseName: map['courseName'] ?? '',
      teacherId: map['teacherId'] ?? '',
      teacherName: map['teacherName'] ?? '',
      type: DocumentType.values.firstWhere(
        (type) => type.name == map['type'],
        orElse: () => DocumentType.other,
      ),
      target: DocumentTarget.values.firstWhere(
        (target) => target.name == map['target'],
        orElse: () => DocumentTarget.all,
      ),
      targetUserIds: List<String>.from(map['targetUserIds'] ?? []),
      uploadDate: (map['uploadDate'] as Timestamp).toDate(),
      lastModified: map['lastModified']?.toDate(),
      downloadCount: map['downloadCount'] ?? 0,
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileSize': fileSize,
      'fileType': fileType,
      'courseId': courseId,
      'courseName': courseName,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'type': type.name,
      'target': target.name,
      'targetUserIds': targetUserIds,
      'uploadDate': Timestamp.fromDate(uploadDate),
      'lastModified': lastModified != null ? Timestamp.fromDate(lastModified!) : null,
      'downloadCount': downloadCount,
      'isActive': isActive,
    };
  }

  DocumentModel copyWith({
    String? id,
    String? title,
    String? description,
    String? fileName,
    String? fileUrl,
    int? fileSize,
    String? fileType,
    String? courseId,
    String? courseName,
    String? teacherId,
    String? teacherName,
    DocumentType? type,
    DocumentTarget? target,
    List<String>? targetUserIds,
    DateTime? uploadDate,
    DateTime? lastModified,
    int? downloadCount,
    bool? isActive,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      fileSize: fileSize ?? this.fileSize,
      fileType: fileType ?? this.fileType,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      type: type ?? this.type,
      target: target ?? this.target,
      targetUserIds: targetUserIds ?? this.targetUserIds,
      uploadDate: uploadDate ?? this.uploadDate,
      lastModified: lastModified ?? this.lastModified,
      downloadCount: downloadCount ?? this.downloadCount,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        fileName,
        fileUrl,
        fileSize,
        fileType,
        courseId,
        courseName,
        teacherId,
        teacherName,
        type,
        target,
        targetUserIds,
        uploadDate,
        lastModified,
        downloadCount,
        isActive,
      ];

  String get typeDisplayName {
    switch (type) {
      case DocumentType.course:
        return 'Cours';
      case DocumentType.tutorial:
        return 'TD';
      case DocumentType.lab:
        return 'TP';
      case DocumentType.exam:
        return 'Examen';
      case DocumentType.resource:
        return 'Ressource';
      case DocumentType.other:
        return 'Autre';
    }
  }

  String get formattedFileSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  bool get isImage => fileType.startsWith('image/');
  bool get isPdf => fileType == 'application/pdf';
  bool get isDoc => fileType.contains('document') || fileType.contains('word');
  bool get isSheet => fileType.contains('sheet') || fileType.contains('excel');
  bool get isPresentation => fileType.contains('presentation') || fileType.contains('powerpoint');
}
