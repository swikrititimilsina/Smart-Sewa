/// Model representing a citizen's application for a government service.
class ApplicationModel {
  final String id;
  final String serviceName;
  final String applicantName;
  final String applicantPhone;
  final String status; // 'Pending', 'Approved', 'Rejected'
  final DateTime submittedAt;
  final Map<String, String> formData;

  const ApplicationModel({
    required this.id,
    required this.serviceName,
    required this.applicantName,
    required this.applicantPhone,
    required this.status,
    required this.submittedAt,
    this.formData = const {},
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['id'] ?? '',
      serviceName: json['serviceName'] ?? '',
      applicantName: json['applicantName'] ?? '',
      applicantPhone: json['applicantPhone'] ?? '',
      status: json['status'] ?? 'Pending',
      submittedAt: DateTime.tryParse(json['submittedAt'] ?? '') ?? DateTime.now(),
      formData: Map<String, String>.from(json['formData'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceName': serviceName,
      'applicantName': applicantName,
      'applicantPhone': applicantPhone,
      'status': status,
      'submittedAt': submittedAt.toIso8601String(),
      'formData': formData,
    };
  }
}
