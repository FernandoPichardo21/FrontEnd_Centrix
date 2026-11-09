class CreatedUser {
  const CreatedUser({required this.id});

  final String id;

  factory CreatedUser.fromJson(Map<String, dynamic> json) {
    return CreatedUser(id: json['id'] as String);
  }
}
