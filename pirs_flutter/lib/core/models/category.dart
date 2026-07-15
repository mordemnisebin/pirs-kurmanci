/// Modela kategoriyê.
class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    this.nameKu,
    this.description,
    this.icon,
    this.color,
    this.questionCount = 0,
  });

  final String id;
  final String name;
  final String? nameKu;
  final String? description;
  final String? icon;
  final String? color;
  final int questionCount;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      nameKu: json['nameKu'] as String?,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      questionCount:
          (json['_count']?['questions'] ?? json['questionCount'] ?? 0) as int,
    );
  }

  /// Kategorî rengê hex'ê vedigere Color objesine
  int get colorValue {
    if (color == null || color!.isEmpty) return 0xFF3B82F6;
    String hex = color!.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return int.parse(hex, radix: 16);
  }
}
