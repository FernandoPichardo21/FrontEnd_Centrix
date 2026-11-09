import 'dart:typed_data';

import 'package:centrix/features/tickets/models/ticket.dart';
import 'package:centrix/features/tickets/models/ticket_evidence.dart';
import 'package:centrix/features/tickets/models/ticket_evidence_file.dart';
import 'package:centrix/features/tickets/models/ticket_model.dart';
import 'package:centrix/features/tickets/viewmodels/ticket_detail_view_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

const sampleEvidence = TicketEvidence(
  evidenceId: 'evidence-1',
  ticketId: 'ticket-1',
  mimeType: 'image/png',
  size: 9,
  createdAt: null,
  signedUrl: 'https://example.test/signed',
);

class FakeEvidenceTicketModel extends TicketModel {
  int uploads = 0;

  @override
  Future<Ticket> getById(String ticketId, String token) async => const Ticket(
    ticketId: 'ticket-1',
    title: 'Equipo dañado',
    description: 'No enciende',
    priority: 'Alta',
    status: 'Abierto',
    departmentId: 'department-1',
    authorName: 'María',
    assignedToName: 'Sin asignar',
  );

  @override
  Future<List<TicketEvidence>> getEvidences(
    String ticketId,
    String token,
  ) async => const [];

  @override
  Future<TicketEvidence> attachEvidence(
    String ticketId,
    TicketEvidenceFile file,
    String token,
  ) async {
    uploads++;
    return sampleEvidence;
  }
}

void main() {
  test('el modelo envía multipart y lee las URLs firmadas', () async {
    final requests = <RequestOptions>[];
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options);
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              statusCode: options.method == 'POST' ? 201 : 200,
              data: {
                'success': true,
                'data': options.method == 'POST'
                    ? {
                        'evidenceId': 'evidence-1',
                        'ticketId': 'ticket-1',
                        'mimeType': 'image/png',
                        'size': 9,
                        'createdAt': '2026-11-03T12:00:00Z',
                        'signedUrl': 'https://example.test/signed',
                      }
                    : [
                        {
                          'evidenceId': 'evidence-1',
                          'ticketId': 'ticket-1',
                          'mimeType': 'image/png',
                          'size': 9,
                          'createdAt': '2026-11-03T12:00:00Z',
                          'signedUrl': 'https://example.test/signed',
                        },
                      ],
              },
            ),
          );
        },
      ),
    );

    final model = TicketModel(client: dio);
    final file = TicketEvidenceFile(
      name: 'prueba.png',
      bytes: Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10, 1]),
      mimeType: 'image/png',
    );
    final uploaded = await model.attachEvidence('ticket-1', file, 'jwt-test');
    final listed = await model.getEvidences('ticket-1', 'jwt-test');

    expect(uploaded.evidenceId, 'evidence-1');
    expect(listed.single.signedUrl, 'https://example.test/signed');
    expect(requests.map((r) => '${r.method} ${r.path}'), [
      'POST /api/tickets/ticket-1/evidences',
      'GET /api/tickets/ticket-1/evidences',
    ]);
    expect(
      requests.every((r) => r.headers['Authorization'] == 'Bearer jwt-test'),
      isTrue,
    );
    final form = requests.first.data as FormData;
    expect(form.files.single.key, 'file');
    expect(form.files.single.value.filename, 'prueba.png');
    expect(form.files.single.value.contentType.toString(), 'image/png');
  });

  test('el ViewModel valida tamaño y añade la evidencia al ticket', () async {
    final model = FakeEvidenceTicketModel();
    final viewModel = TicketDetailViewModel(model, 'ticket-1', false);
    await viewModel.load('jwt-test');

    viewModel.selectEvidence(
      TicketEvidenceFile(
        name: 'grande.png',
        bytes: Uint8List(5 * 1024 * 1024 + 1),
        mimeType: 'image/png',
      ),
    );
    expect(viewModel.selectedEvidence, isNull);
    expect(viewModel.evidenceError, contains('5 MB'));

    viewModel.selectEvidence(
      TicketEvidenceFile(
        name: 'prueba.png',
        bytes: Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10, 1]),
        mimeType: 'image/png',
      ),
    );
    await viewModel.uploadEvidence('jwt-test');
    expect(model.uploads, 1);
    expect(viewModel.evidences.single.evidenceId, 'evidence-1');
    expect(viewModel.selectedEvidence, isNull);
    viewModel.dispose();
  });
}
