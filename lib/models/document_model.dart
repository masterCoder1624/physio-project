class DocumentModel {
  final String id;
  final String patientId;
  final String? physiotherapistId;
  final String fileId;
  final String fileName;
  final String originalFileName;
  final String fileType;
  final String mimeType;
  final int fileSize;
  final String fileSizeFormatted;
  final String category;
  final String? description;
  final String uploadedBy;
  final String uploadedByRole;
  final String? uploadedByName;
  final String? appointmentId;
  final String? clinicalNoteId;
  final String? assessmentId;
  final String? downloadUrl;
  final DateTime createdAt;
  final bool isActive;

  DocumentModel({
    required this.id,
    required this.patientId,
    this.physiotherapistId,
    required this.fileId,
    required this.fileName,
    required this.originalFileName,
    this.fileType = 'pdf',
    this.mimeType = 'application/pdf',
    this.fileSize = 0,
    this.fileSizeFormatted = '0 KB',
    this.category = 'Reports',
    this.description,
    this.uploadedBy = '',
    this.uploadedByRole = 'physiotherapist',
    this.uploadedByName,
    this.appointmentId,
    this.clinicalNoteId,
    this.assessmentId,
    this.downloadUrl,
    DateTime? createdAt,
    this.isActive = true,
  }) : createdAt = createdAt ?? DateTime.now();

  String get dateFormatted {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final day = createdAt.day.toString().padLeft(2, '0');
    final month = months[createdAt.month - 1];
    final year = createdAt.year;
    return '$day $month $year';
  }

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      parsedDate = json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now();
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return DocumentModel(
      id: json['id']?.toString() ?? '',
      patientId: json['patient_id']?.toString() ?? '',
      physiotherapistId: json['physiotherapist_id']?.toString(),
      fileId: json['file_id']?.toString() ?? '',
      fileName: json['file_name']?.toString() ?? '',
      originalFileName: json['original_file_name']?.toString() ??
          json['title']?.toString() ??
          'Document',
      fileType: json['file_type']?.toString() ?? 'pdf',
      mimeType: json['mime_type']?.toString() ?? 'application/pdf',
      fileSize: (json['file_size'] as num?)?.toInt() ??
          (json['file_size_bytes'] as num?)?.toInt() ??
          0,
      fileSizeFormatted: json['file_size_formatted']?.toString() ??
          json['size']?.toString() ??
          '0 KB',
      category: json['document_category']?.toString() ??
          json['category']?.toString() ??
          'Reports',
      description: json['description']?.toString(),
      uploadedBy: json['uploaded_by']?.toString() ?? '',
      uploadedByRole: json['uploaded_by_role']?.toString() ?? 'physiotherapist',
      uploadedByName: json['uploaded_by_name']?.toString(),
      appointmentId: json['appointment_id']?.toString(),
      clinicalNoteId: json['clinical_note_id']?.toString(),
      assessmentId: json['assessment_id']?.toString(),
      downloadUrl: json['download_url']?.toString(),
      createdAt: parsedDate,
      isActive: json['is_active'] != false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'patient_id': patientId,
        'physiotherapist_id': physiotherapistId,
        'file_id': fileId,
        'file_name': fileName,
        'original_file_name': originalFileName,
        'file_type': fileType,
        'mime_type': mimeType,
        'file_size': fileSize,
        'file_size_formatted': fileSizeFormatted,
        'document_category': category,
        'description': description,
        'uploaded_by': uploadedBy,
        'uploaded_by_role': uploadedByRole,
        'uploaded_by_name': uploadedByName,
        'appointment_id': appointmentId,
        'clinical_note_id': clinicalNoteId,
        'assessment_id': assessmentId,
        'download_url': downloadUrl,
        'created_at': createdAt.toIso8601String(),
        'is_active': isActive,
      };
}
