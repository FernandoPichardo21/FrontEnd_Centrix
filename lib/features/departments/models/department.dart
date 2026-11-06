class Department {
  const Department({
    required this.departmentId,
    required this.name,
    this.description,
  });

  final String departmentId;
  final String name;
  final String? description;

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      departmentId: json['departmentId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }
}
