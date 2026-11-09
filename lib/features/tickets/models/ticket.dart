class Ticket {
  const Ticket({
    required this.ticketId,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.departmentId,
    required this.authorName,
    required this.assignedToName,
    this.createdAtIso,
    this.updatedAtIso,
    this.createdById,
    this.assignedToId,
  });

  final String ticketId;
  final String title;
  final String description;
  final String priority;
  final String status;
  final String departmentId;
  final String authorName;
  final String assignedToName;
  final String? createdAtIso;
  final String? updatedAtIso;
  final String? createdById;
  final String? assignedToId;

  DateTime? get createdAt =>
      createdAtIso == null ? null : DateTime.tryParse(createdAtIso!);

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      ticketId: json['ticketId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      priority: json['priority'] as String,
      status: json['status'] as String,
      departmentId: json['departmentId'] as String,
      createdAtIso: json['createdAtIso'] as String?,
      updatedAtIso: json['updatedAtIso'] as String?,
      createdById: json['createdById'] as String?,
      assignedToId: json['assignedToId'] as String?,
      authorName: json['authorName'] as String,
      assignedToName: json['assignedToName'] as String,
    );
  }
}
