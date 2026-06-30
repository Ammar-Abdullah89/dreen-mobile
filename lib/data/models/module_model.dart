class ModuleModel {
  final int id;
  final String name;
  final String displayName;
  final String? icon;
  final String? summary;

  ModuleModel({
    required this.id,
    required this.name,
    required this.displayName,
    this.icon,
    this.summary,
  });

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    String? _str(dynamic v) => v is String ? v : null;
    return ModuleModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      displayName: json['display_name'] ?? json['shortdesc'] ?? '',
      icon: _str(json['icon']),
      summary: _str(json['summary']),
    );
  }
}
