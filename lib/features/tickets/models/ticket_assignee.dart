class TicketAssignee {
  const TicketAssignee({
    required this.id,
    required this.fullName,
    required this.email,
  });

  final String id;
  final String fullName;
  final String email;

  factory TicketAssignee.fromJson(Map<String, dynamic> json) => TicketAssignee(
    id: json['id'] as String,
    fullName: json['fullName'] as String,
    email: json['email'] as String,
  );
}
