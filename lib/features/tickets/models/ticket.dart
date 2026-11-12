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
      ticketId: (json['ticketId'] ?? json['id'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      priority: (json['priority'] ?? '') as String,
      status: (json['status'] ?? '') as String,
      departmentId:
          (json['departmentId'] ?? json['department_id'] ?? '') as String,
      createdAtIso: (json['createdAtIso'] ?? json['created_at']) as String?,
      updatedAtIso: (json['updatedAtIso'] ?? json['updated_at']) as String?,
      createdById:
          (json['createdById'] ?? json['createdBy'] ?? json['created_by'])
              as String?,
      assignedToId:
          (json['assignedToId'] ?? json['assignedTo'] ?? json['assigned_to'])
              as String?,
      authorName: (json['authorName'] ?? 'Desconocido') as String,
      assignedToName: (json['assignedToName'] ?? 'Sin asignar') as String,
    );
  }
}
