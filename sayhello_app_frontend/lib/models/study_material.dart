/// StudyMaterial Model
/// Represents a study material document/file uploaded by instructors

class StudyMaterial {
  final String id;
  final String courseId;
  final String title;
  final String description;
  final String type; // pdf, doc, docx, image, jpg, jpeg, png, gif
  final String fileName;
  final String filePath; // Supabase Storage path
  final String fileSize;
  final DateTime uploadDate;
  final String uploadTime;
  final String? downloadUrl; // Supabase public URL

  StudyMaterial({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.type,
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.uploadDate,
    required this.uploadTime,
    this.downloadUrl,
  });

  /// Create StudyMaterial from JSON
  factory StudyMaterial.fromJson(Map<String, dynamic> json) {
    return StudyMaterial(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      courseId: json['course_id']?.toString() ?? '',
      title:
          json['title']?.toString() ?? json['material_title']?.toString() ?? '',
      description:
          json['description']?.toString() ??
          json['material_description']?.toString() ??
          '',
      type: json['type']?.toString() ?? json['material_type']?.toString() ?? '',
      fileName:
          json['file_name']?.toString() ??
          json['material_title']?.toString() ??
          '',
      filePath:
          json['file_path']?.toString() ??
          json['material_link']?.toString() ??
          '',
      fileSize: json['file_size']?.toString() ?? '0 KB',
      uploadDate:
          DateTime.tryParse(
            json['upload_date']?.toString() ??
                json['created_at']?.toString() ??
                '',
          ) ??
          DateTime.now(),
      uploadTime: json['upload_time']?.toString() ?? '',
      downloadUrl:
          json['download_url']?.toString() ?? json['material_link']?.toString(),
    );
  }

  /// Convert StudyMaterial to JSON for database operations
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'title': title,
      'material_title': title,
      'description': description,
      'material_description': description,
      'type': type,
      'material_type': type,
      'file_name': fileName,
      'file_path': filePath,
      'material_link': filePath,
      'file_size': fileSize,
      'upload_time': uploadTime,
      'download_url': downloadUrl,
    };
  }

  /// Create a copy of StudyMaterial with updated fields
  StudyMaterial copyWith({
    String? id,
    String? courseId,
    String? title,
    String? description,
    String? type,
    String? fileName,
    String? filePath,
    String? fileSize,
    DateTime? uploadDate,
    String? uploadTime,
    String? downloadUrl,
  }) {
    return StudyMaterial(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      fileSize: fileSize ?? this.fileSize,
      uploadDate: uploadDate ?? this.uploadDate,
      uploadTime: uploadTime ?? this.uploadTime,
      downloadUrl: downloadUrl ?? this.downloadUrl,
    );
  }

  @override
  String toString() {
    return 'StudyMaterial{id: $id, title: $title, type: $type, fileName: $fileName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StudyMaterial && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
