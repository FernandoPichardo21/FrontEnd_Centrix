enum ManagerRequestStatus {
  pending('Pendiente'),
  approved('Aprobada'),
  rejected('Rechazada');

  const ManagerRequestStatus(this.label);
  final String label;
}

enum ManagerCategory {
  equipment('Equipo y mobiliario'),
  software('Software y licencias'),
  operations('Insumos y operación'),
  maintenance('Mantenimiento');

  const ManagerCategory(this.label);
  final String label;
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
}
