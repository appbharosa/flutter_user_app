class CoverageCategory {
  final int id;
  final String name;

  CoverageCategory({required this.id, required this.name});

  factory CoverageCategory.fromJson(Map<String, dynamic> json) {
    return CoverageCategory(
      id: json['id'],
      name: json['name'],
    );
  }
}