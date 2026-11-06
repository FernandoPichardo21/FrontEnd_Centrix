import 'dart:typed_data';

class TicketEvidenceFile {
  const TicketEvidenceFile({
    required this.name,
    required this.bytes,
    required this.mimeType,
  });

  final String name;
  final Uint8List bytes;
  final String mimeType;

  bool get isImage => mimeType.startsWith('image/');
}
