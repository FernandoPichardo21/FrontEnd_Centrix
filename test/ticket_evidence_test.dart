import 'dart:typed_data';

import 'package:centrix/features/tickets/models/ticket.dart';
import 'package:centrix/features/tickets/models/create_ticket_request.dart';
import 'package:centrix/features/tickets/models/created_ticket.dart';
import 'package:centrix/features/tickets/models/ticket_priority.dart';
import 'package:centrix/features/tickets/viewmodels/create_ticket_view_model.dart';
import 'package:centrix/features/departments/models/department_model.dart';
import 'package:centrix/core/network/api_exception.dart';
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
  int creates = 0;
  bool failUpload = false;
  bool failCreate = false;
  final operations = <String>[];
  final uploadedTicketIds = <String>[];

  @override
  Future<CreatedTicket> create(
    CreateTicketRequest request,
    String token,
  ) async {
    creates++;
    operations.add('create');
    if (failCreate) throw const ApiException('No se pudo crear el ticket.');
    return const CreatedTicket(id: 'ticket-1');
  }

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
  ) async => const [sampleEvidence];

  @override
  Future<TicketEvidence> attachEvidence(
    String ticketId,
    TicketEvidenceFile file,
    String token,
  ) async {
    uploads++;
    uploadedTicketIds.add(ticketId);
    operations.add('upload');
    if (failUpload)
      throw const ApiException('Storage no disponible', statusCode: 500);
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

  CreateTicketViewModel creation(FakeEvidenceTicketModel model) =>
      CreateTicketViewModel(model, DepartmentModel())
        ..selectDepartment('department-1')
        ..selectPriority(TicketPriority.alta);

  TicketEvidenceFile selectedFile() => TicketEvidenceFile(
    name: 'prueba.png',
    bytes: Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10, 1]),
    mimeType: 'image/png',
  );

  test(
    'crear valida el archivo y lo adjunta después de obtener el ID',
    () async {
      final model = FakeEvidenceTicketModel();
      final viewModel = creation(model);
      viewModel.selectEvidence(
        TicketEvidenceFile(
          name: 'grande.png',
          bytes: Uint8List(5 * 1024 * 1024 + 1),
          mimeType: 'image/png',
        ),
      );
      expect(viewModel.selectedEvidence, isNull);
      expect(viewModel.evidenceError, contains('5 MB'));
      viewModel.selectEvidence(selectedFile());
      expect(
        await viewModel.submit(
          title: 'Equipo',
          description: 'No enciende',
          token: 'jwt',
        ),
        isTrue,
      );
      expect(model.operations, ['create', 'upload']);
      expect(model.uploadedTicketIds, ['ticket-1']);
      expect(viewModel.evidenceUploaded, isTrue);
      expect(viewModel.selectedEvidence, isNull);
      expect(viewModel.hasPendingEvidence, isFalse);
      viewModel.dispose();
    },
  );

  test(
    'si falla la evidencia reintenta la subida sin crear otro ticket',
    () async {
      final model = FakeEvidenceTicketModel()..failUpload = true;
      final viewModel = creation(model)..selectEvidence(selectedFile());
      expect(
        await viewModel.submit(
          title: 'Equipo',
          description: 'No enciende',
          token: 'jwt',
        ),
        isTrue,
      );
      expect(viewModel.createdTicketId, 'ticket-1');
      expect(viewModel.hasPendingEvidence, isTrue);
      expect(viewModel.evidenceError, 'Storage no disponible');
      expect(
        await viewModel.submit(
          title: 'Equipo',
          description: 'No enciende',
          token: 'jwt',
        ),
        isFalse,
      );
      model.failUpload = false;
      await viewModel.retryEvidenceUpload('jwt');
      expect(model.creates, 1);
      expect(model.uploads, 2);
      expect(model.uploadedTicketIds, ['ticket-1', 'ticket-1']);
      expect(viewModel.evidenceUploaded, isTrue);
      expect(viewModel.isSubmitting, isFalse);
      viewModel.reset();
      expect(viewModel.createdTicketId, isNull);
      expect(viewModel.evidenceUploaded, isFalse);
      viewModel.dispose();
    },
  );

  test(
    'la evidencia es opcional y una creación fallida no sube archivos',
    () async {
      final model = FakeEvidenceTicketModel();
      final viewModel = creation(model);
      await viewModel.submit(
        title: 'Equipo',
        description: 'No enciende',
        token: 'jwt',
      );
      expect(model.creates, 1);
      expect(model.uploads, 0);
      viewModel.reset();
      viewModel.selectDepartment('department-1');
      viewModel.selectPriority(TicketPriority.alta);
      viewModel.selectEvidence(selectedFile());
      model.failCreate = true;
      expect(
        await viewModel.submit(
          title: 'Equipo',
          description: 'No enciende',
          token: 'jwt',
        ),
        isFalse,
      );
      expect(viewModel.createdTicketId, isNull);
      expect(viewModel.selectedEvidence, isNotNull);
      expect(model.uploads, 0);
      viewModel.dispose();
    },
  );

  test('el detalle consulta evidencias sin efectuar subidas', () async {
    final model = FakeEvidenceTicketModel();
    final viewModel = TicketDetailViewModel(model, 'ticket-1', false);
    await viewModel.load('jwt');
    expect(viewModel.evidences.single.evidenceId, 'evidence-1');
    expect(model.uploads, 0);
    expect(model.creates, 0);
    viewModel.dispose();
  });
}
