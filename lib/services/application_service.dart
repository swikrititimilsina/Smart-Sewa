import '../models/application_model.dart';
import '../utils/hash_util.dart';

/// Service for managing citizen applications.
class ApplicationService {
  // In-memory store for demo purposes
  static final List<ApplicationModel> _applications = [];

  /// Submits a new application and returns the application ID.
  static String submitApplication({
    required String serviceName,
    required String applicantName,
    required String applicantPhone,
    Map<String, String> formData = const {},
  }) {
    final id = HashUtil.generateId();
    final application = ApplicationModel(
      id: id,
      serviceName: serviceName,
      applicantName: applicantName,
      applicantPhone: applicantPhone,
      status: 'Pending',
      submittedAt: DateTime.now(),
      formData: formData,
    );
    _applications.add(application);
    return id;
  }

  /// Returns all applications for a given phone number.
  static List<ApplicationModel> getApplicationsForUser(String phone) {
    return _applications
        .where((app) => app.applicantPhone == phone)
        .toList();
  }

  /// Returns all applications (for admin use).
  static List<ApplicationModel> getAllApplications() {
    return List.unmodifiable(_applications);
  }

  /// Updates the status of an application by ID.
  static bool updateStatus(String id, String newStatus) {
    final index = _applications.indexWhere((app) => app.id == id);
    if (index == -1) return false;
    final old = _applications[index];
    _applications[index] = ApplicationModel(
      id: old.id,
      serviceName: old.serviceName,
      applicantName: old.applicantName,
      applicantPhone: old.applicantPhone,
      status: newStatus,
      submittedAt: old.submittedAt,
      formData: old.formData,
    );
    return true;
  }
}
