enum TicketStatus {
  abierto('Abierto', 'Abierto'),
  enRevision('En revision', 'En revisión'),
  enProgreso('En progreso', 'En progreso'),
  resuelto('Resuelto', 'Resuelto'),
  cerrado('Cerrado', 'Cerrado'),
  rechazado('Rechazado', 'Rechazado');

  const TicketStatus(this.apiValue, this.label);

  final String apiValue;
  final String label;

  bool get requiresComment =>
      this == resuelto || this == cerrado || this == rechazado;

  bool canTransitionTo(TicketStatus target) => switch (this) {
    abierto => [enRevision, enProgreso, cerrado, rechazado].contains(target),
    enRevision => [enProgreso, resuelto, cerrado, rechazado].contains(target),
    enProgreso => [enRevision, resuelto, cerrado].contains(target),
    resuelto => [enProgreso, cerrado].contains(target),
    cerrado || rechazado => false,
  };

  static TicketStatus? fromApi(String value) {
    final normalized = value
        .trim()
        .toLowerCase()
        .replaceAll('_', ' ')
        .replaceAll('ó', 'o');
    return values
        .where((status) => status.apiValue.toLowerCase() == normalized)
        .firstOrNull;
  }
}
