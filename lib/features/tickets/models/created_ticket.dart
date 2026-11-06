class CreatedTicket {
  const CreatedTicket({required this.id});

  final String id;

  factory CreatedTicket.fromJson(Map<String, dynamic> json) {
    return CreatedTicket(id: json['id'] as String);
  }
}
