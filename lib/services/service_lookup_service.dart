import '../data/local_data_source.dart';
import '../models/service_model.dart';

/// Service for looking up available government services.
class ServiceLookupService {
  static List<ServiceModel>? _services;

  /// Loads services from the local JSON data source.
  static Future<List<ServiceModel>> loadServices() async {
    if (_services != null) return _services!;

    try {
      final jsonList = await LocalDataSource.loadServices();
      _services = jsonList
          .map((json) => ServiceModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      _services = [];
    }
    return _services!;
  }

  /// Returns a service by its ID.
  static ServiceModel? getServiceById(String id) {
    return _services?.firstWhere(
      (s) => s.id == id,
      orElse: () => const ServiceModel(
        id: '',
        name: 'Unknown',
        description: '',
        category: '',
      ),
    );
  }

  /// Returns all services matching a category.
  static List<ServiceModel> getServicesByCategory(String category) {
    return _services
            ?.where((s) => s.category.toLowerCase() == category.toLowerCase())
            .toList() ??
        [];
  }
}
