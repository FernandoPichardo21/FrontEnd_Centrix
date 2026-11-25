enum ManagerRequestStatus {
  pending('Pendiente'),
  approved('Aprobada'),
  rejected('Rechazada');

  const ManagerRequestStatus(this.label);
  final String label;

  static ManagerRequestStatus fromString(String? raw) {
    if (raw == null) return ManagerRequestStatus.pending;
    final cleaned = raw.toLowerCase().trim();
    if (cleaned.contains('aprob')) return ManagerRequestStatus.approved;
    if (cleaned.contains('rechaz')) return ManagerRequestStatus.rejected;
    return ManagerRequestStatus.pending;
  }
}

enum ManagerCategory {
  equipment('Equipo y mobiliario'),
  software('Software y licencias'),
  operations('Insumos y operación'),
  maintenance('Mantenimiento');

  const ManagerCategory(this.label);
  final String label;

  static ManagerCategory fromString(String? raw) {
    if (raw == null) return ManagerCategory.operations;
    final cleaned = raw.toLowerCase().trim();
    if (cleaned.contains('equip')) return ManagerCategory.equipment;
    if (cleaned.contains('soft') || cleaned.contains('licen')) {
      return ManagerCategory.software;
    }
    if (cleaned.contains('manten') || cleaned.contains('mobil')) {
      return ManagerCategory.maintenance;
    }
    return ManagerCategory.operations;
  }

  String toBackendCategory() {
    switch (this) {
      case ManagerCategory.equipment:
        return 'Equipo';
      case ManagerCategory.software:
        return 'Equipo';
      case ManagerCategory.operations:
        return 'Material';
      case ManagerCategory.maintenance:
        return 'Mobiliario';
    }
  }
}

enum ManagerSection {
  approvals('aprobaciones', 'Aprobaciones'),
  budget('presupuesto', 'Presupuesto'),
  requests('solicitudes', 'Solicitudes del departamento'),
  reports('reportes', 'Reportes');

  const ManagerSection(this.path, this.label);
  final String path;
  final String label;
}

class ManagerRequest {
  const ManagerRequest({
    required this.id,
    required this.title,
    required this.applicant,
    required this.category,
    required this.amountCents,
    required this.date,
    required this.description,
    this.status = ManagerRequestStatus.pending,
    this.priority = 'Normal',
    this.attachment,
    this.comment,
  });

  final String id;
  final String title;
  final String applicant;
  final ManagerCategory category;
  final int amountCents;
  final DateTime date;
  final String description;
  final ManagerRequestStatus status;
  final String priority;
  final String? attachment;
  final String? comment;

  ManagerRequest decide(ManagerRequestStatus value, String note) =>
      ManagerRequest(
        id: id,
        title: title,
        applicant: applicant,
        category: category,
        amountCents: amountCents,
        date: date,
        description: description,
        status: value,
        priority: priority,
        attachment: attachment,
        comment: note,
      );

  factory ManagerRequest.fromJson(Map<String, dynamic> json) {
    final rawAmount =
        json['estimatedAmount'] ??
        json['estimated_amount'] ??
        json['amountCents'];
    final int amountInCents = rawAmount is int
        ? rawAmount
        : rawAmount is num
        ? (rawAmount * 100).round()
        : 0;

    DateTime parsedDate = DateTime.now();
    final rawDate =
        json['createdAtIso'] ?? json['createdAt'] ?? json['created_at'];
    if (rawDate != null) {
      parsedDate = DateTime.tryParse(rawDate.toString()) ?? DateTime.now();
    }

    return ManagerRequest(
      id: (json['requestId'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      applicant: (json['authorName'] ?? json['applicant'] ?? 'Colaborador')
          .toString(),
      category: ManagerCategory.fromString((json['category'] ?? '').toString()),
      amountCents: amountInCents,
      date: parsedDate,
      description: (json['description'] ?? '').toString(),
      status: ManagerRequestStatus.fromString(
        (json['status'] ?? '').toString(),
      ),
      priority: (json['priority'] ?? 'Normal').toString(),
      attachment: json['attachment'] as String?,
      comment:
          (json['rejectionReason'] ??
                  json['comment'] ??
                  json['rejection_reason'])
              as String?,
    );
  }
}
