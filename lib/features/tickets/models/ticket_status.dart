enum TicketStatus {
  abierto('Abierto', 'Abierto'),
  enRevision('En revision', 'En revisión'),
  enProgreso('En progreso', 'En progreso'),
  resuelto('Resuelto', 'Resuelto'),
  cerrado('Cerrado', 'Cerrado');

  const TicketStatus(this.apiValue, this.label);

  final String apiValue;
  final String label;
}
