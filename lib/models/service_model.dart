/// Model representing a government service available in the app.
class ServiceModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final String iconName;
  final List<String> requiredDocuments;
  final String estimatedTime;

  const ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.iconName = 'description',
    this.requiredDocuments = const [],
    this.estimatedTime = 'N/A',
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      iconName: json['iconName'] ?? 'description',
      requiredDocuments: List<String>.from(json['requiredDocuments'] ?? []),
      estimatedTime: json['estimatedTime'] ?? 'N/A',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'iconName': iconName,
      'requiredDocuments': requiredDocuments,
      'estimatedTime': estimatedTime,
    };
  }
}
