import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:centrix/core/network/api_exception.dart';
import 'package:centrix/features/departments/models/department_model.dart';
import 'package:centrix/features/tickets/models/ticket_evidence_file.dart';
import 'package:centrix/features/tickets/models/ticket_model.dart';
import 'package:centrix/features/tickets/models/ticket_priority.dart';
import 'package:centrix/features/tickets/models/ticket_status.dart';
import 'package:centrix/features/tickets/viewmodels/create_ticket_view_model.dart';
import 'package:centrix/features/tickets/viewmodels/ticket_detail_view_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final backend = Platform.environment['CENTRIX_BACKEND_DIR'];
  final node = Platform.environment['NODE_BINARY'] ?? 'node';

  test(
    'MVVM crea con evidencia, consulta, asigna y resuelve contra Express real',
    () async {
      final process = await Process.start(node, [
        '$backend/tests/fixtures/frontendContractServer.js',
      ]);
      final errors = StringBuffer();
      final stderrSubscription = process.stderr
          .transform(utf8.decoder)
          .listen(errors.write);
      final ready = Completer<Map<String, dynamic>>();
      final stdoutSubscription = process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
            if (line.startsWith('CONTRACT_READY ') && !ready.isCompleted) {
              ready.complete(
                jsonDecode(line.substring('CONTRACT_READY '.length))
                    as Map<String, dynamic>,
              );
            }
          });
      addTearDown(() async {
        process.kill();
        await process.exitCode.timeout(const Duration(seconds: 10));
        await stdoutSubscription.cancel();
        await stderrSubscription.cancel();
      });
      final fixture = await ready.future.timeout(
        const Duration(seconds: 25),
        onTimeout: () =>
            throw StateError('No inició el backend de prueba: $errors'),
      );
      final tokens = fixture['tokens'] as Map<String, dynamic>;
      final ids = fixture['ids'] as Map<String, dynamic>;
      final creatorToken = tokens['creator'] as String;
      final managerToken = tokens['manager'] as String;
      final dio = Dio(
        BaseOptions(
          baseUrl: 'http://127.0.0.1:${fixture['port']}',
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      addTearDown(() => dio.close(force: true));
      final model = TicketModel(client: dio);
      final create = CreateTicketViewModel(model, DepartmentModel());
      addTearDown(create.dispose);
      create.selectDepartment(ids['department'] as String);
      create.selectPriority(TicketPriority.alta);
      create.selectEvidence(
        TicketEvidenceFile(
          name: 'red.png',
          mimeType: 'image/png',
          bytes: Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10, 1]),
        ),
      );
      expect(
        await create.submit(
          title: 'Equipo sin red',
          description: 'No conecta',
          token: creatorToken,
        ),
        isTrue,
      );
      expect(create.evidenceError, isNull);
      expect(create.evidenceUploaded, isTrue);
      final ticketId = create.createdTicketId!;
      expect(
        (await model.getMyTickets(creatorToken)).single.ticketId,
        ticketId,
      );
      expect(
        (await model.getByDepartment(
          ids['department'] as String,
          managerToken,
        )).single.ticketId,
        ticketId,
      );
      expect(
        (await model.getEvidences(ticketId, creatorToken)).single.mimeType,
        'image/png',
      );

      final detail = TicketDetailViewModel(model, ticketId, true);
      addTearDown(detail.dispose);
      await detail.load(managerToken);
      expect(detail.errorMessage, isNull);
      expect(
        detail.evidences.single.signedUrl,
        contains('evidencias/tickets/'),
      );
      expect(detail.assignees.single.id, ids['solver']);
      detail.selectAssignee(ids['solver'] as String);
      await detail.assign(managerToken);
      expect(detail.ticket!.assignedToId, ids['solver']);
      detail.selectStatus(TicketStatus.enProgreso);
      await detail.updateStatus(managerToken);
      expect(detail.ticket!.status, 'En progreso');
      detail.selectStatus(TicketStatus.resuelto);
      await detail.updateStatus(managerToken);
      expect(detail.actionMessage, contains('comentario'));
      expect(detail.ticket!.status, 'En progreso');
      detail.setStatusComment('Se restableció la conexión');
      await detail.updateStatus(managerToken);
      expect(detail.ticket!.status, 'Resuelto');
      expect(await model.getPendingTickets(managerToken), isEmpty);
      expect((await model.getMyTickets(creatorToken)).length, 1);
      await expectLater(
        model.getEvidences(
          '30000000-0000-4000-8000-000000000099',
          creatorToken,
        ),
        throwsA(
          isA<ApiException>().having((error) => error.statusCode, 'HTTP', 404),
        ),
      );
    },
    skip: backend == null
        ? 'Define CENTRIX_BACKEND_DIR para la prueba HTTP entre proyectos.'
        : false,
    timeout: const Timeout(Duration(seconds: 60)),
  );
}
