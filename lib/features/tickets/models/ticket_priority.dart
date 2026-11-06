enum TicketPriority {
  baja('Baja', 'Baja'),
  media('Media', 'Media'),
  alta('Alta', 'Alta'),
  critica('Critica', 'Crítica');

  const TicketPriority(this.apiValue, this.label);

  final String apiValue;
  final String label;
}
