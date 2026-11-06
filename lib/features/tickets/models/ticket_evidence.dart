class TicketEvidence {
  const TicketEvidence({
    required this.evidenceId,
    required this.ticketId,
    required this.mimeType,
    required this.size,
    required this.createdAt,
    required this.signedUrl,
  });

  final String evidenceId;
  final String ticketId;
  final String mimeType;
  final int size;
  final DateTime? createdAt;
  final String signedUrl;

  bool get isImage => mimeType.startsWith('image/');

  factory TicketEvidence.fromJson(Map<String, dynamic> json) => TicketEvidence(
    evidenceId: json['evidenceId'] as String,
    ticketId: json['ticketId'] as String,
    mimeType: json['mimeType'] as String,
    size: (json['size'] as num).toInt(),
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
    signedUrl: json['signedUrl'] as String,
  );
}
