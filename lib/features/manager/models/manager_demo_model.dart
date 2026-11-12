import 'manager_request.dart';

/// Fixtures for the visual prototype. This model has no network or storage dependency.
class ManagerDemoModel {
  static const department = 'Operaciones';
  static const year = 2026;

  Map<ManagerCategory, int> get allocations => {
    ManagerCategory.equipment: 5000000,
    ManagerCategory.software: 3000000,
    ManagerCategory.operations: 2500000,
    ManagerCategory.maintenance: 1500000,
  };

  Map<ManagerCategory, int> get previousSpend => {
    ManagerCategory.equipment: 1800000,
    ManagerCategory.software: 600000,
    ManagerCategory.operations: 820000,
    ManagerCategory.maintenance: 0,
  };

  List<ManagerRequest> get requests => [
    ManagerRequest(
      id: 'SOL-0418',
      title: 'Laptop para el equipo de operaciones',
      applicant: 'Lucía Mendoza',
      category: ManagerCategory.equipment,
      amountCents: 1850000,
      date: DateTime(2026, 11, 11),
      priority: 'Alta',
      attachment: 'Cotización de equipo.pdf',
      description: 'Reemplazo de equipo para la coordinación de inventario. La laptop actual presenta fallas recurrentes y limita el seguimiento de las entregas.',
    ),
    ManagerRequest(
      id: 'SOL-0417',
      title: 'Insumos para el cierre de mes',
      applicant: 'Daniel Rivera',
      category: ManagerCategory.operations,
      amountCents: 480000,
      date: DateTime(2026, 11, 10),
      attachment: 'Lista de insumos.pdf',
      description: 'Compra de etiquetas, papel y material de empaque para completar las actividades del departamento durante noviembre.',
    ),
    ManagerRequest(
      id: 'SOL-0416',
      title: 'Mantenimiento de la red interna',
      applicant: 'Andrea Sánchez',
      category: ManagerCategory.maintenance,
      amountCents: 720000,
      date: DateTime(2026, 11, 9),
      priority: 'Alta',
      attachment: 'Propuesta de servicio.pdf',
      description: 'Servicio preventivo de los puntos de red y revisión del cableado en el área de operaciones para evitar interrupciones.',
    ),
    ManagerRequest(
      id: 'SOL-0414',
      title: 'Renovación de licencias de trabajo',
      applicant: 'Omar Rojas',
      category: ManagerCategory.software,
      amountCents: 1200000,
      date: DateTime(2026, 11, 8),
      status: ManagerRequestStatus.approved,
      description: 'Renovación anual de las herramientas de planeación y seguimiento del equipo.',
      comment: 'Renovación autorizada para mantener la operación.',
    ),
    ManagerRequest(
      id: 'SOL-0412',
      title: 'Sillas ergonómicas para el área',
      applicant: 'Sofía Luna',
      category: ManagerCategory.equipment,
      amountCents: 850000,
      date: DateTime(2026, 11, 6),
      status: ManagerRequestStatus.approved,
      description: 'Sustitución de dos sillas del área de atención.',
      comment: 'Compra contemplada en el presupuesto.',
    ),
    ManagerRequest(
      id: 'SOL-0408',
      title: 'Accesorios adicionales de oficina',
      applicant: 'Marco Torres',
      category: ManagerCategory.operations,
      amountCents: 340000,
      date: DateTime(2026, 11, 4),
      status: ManagerRequestStatus.rejected,
      description: 'Accesorios para complementar los espacios de trabajo.',
      comment: 'Ya contamos con accesorios disponibles en almacén.',
    ),
    ManagerRequest(
      id: 'SOL-0371',
      title: 'Herramientas de mantenimiento',
      applicant: 'Andrea Sánchez',
      category: ManagerCategory.maintenance,
      amountCents: 1560000,
      date: DateTime(2026, 10, 21),
      status: ManagerRequestStatus.approved,
      description: 'Equipo para mantenimiento preventivo.',
    ),
    ManagerRequest(
      id: 'SOL-0368',
      title: 'Organizadores de almacén',
      applicant: 'Daniel Rivera',
      category: ManagerCategory.equipment,
      amountCents: 980000,
      date: DateTime(2026, 10, 14),
      status: ManagerRequestStatus.approved,
      description: 'Organización de las estaciones de inventario.',
    ),
    ManagerRequest(
      id: 'SOL-0332',
      title: 'Material de operación',
      applicant: 'Lucía Mendoza',
      category: ManagerCategory.operations,
      amountCents: 1320000,
      date: DateTime(2026, 9, 18),
      status: ManagerRequestStatus.approved,
      description: 'Reposición de material de trabajo.',
    ),
    ManagerRequest(
      id: 'SOL-0325',
      title: 'Licencias adicionales',
      applicant: 'Omar Rojas',
      category: ManagerCategory.software,
      amountCents: 680000,
      date: DateTime(2026, 9, 12),
      status: ManagerRequestStatus.rejected,
      description: 'Ampliación de licencias del departamento.',
    ),
  ];
}
