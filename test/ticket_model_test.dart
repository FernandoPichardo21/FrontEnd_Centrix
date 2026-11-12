import 'package:centrix/features/tickets/models/create_ticket_request.dart';
import 'package:centrix/features/tickets/models/ticket_model.dart';
import 'package:centrix/features/tickets/models/ticket_priority.dart';
import 'package:centrix/features/tickets/models/ticket_status.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'crea un ticket con Bearer y el cuerpo esperado por el backend',
    () async {
      RequestOptions? sentRequest;
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            sentRequest = options;
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 201,
                data: {
                  'success': true,
                  'message': 'Ticket creado exitosamente',
                  'data': {'id': 'ticket-1'},
                },
              ),
            );
          },
        ),
      );

      final result = await TicketModel(client: dio).create(
        const CreateTicketRequest(
          title: ' Falla de equipo ',
          description: ' No enciende ',
          priority: TicketPriority.critica,
          departmentId: 'dep-1',
        ),
        'jwt-test',
      );

      expect(result.id, 'ticket-1');
      expect(sentRequest?.method, 'POST');
      expect(sentRequest?.path, '/api/tickets');
      expect(sentRequest?.headers['Authorization'], 'Bearer jwt-test');
      expect(sentRequest?.data, {
        'title': 'Falla de equipo',
        'description': 'No enciende',
        'priority': 'Critica',
        'department_id': 'dep-1',
      });
    },
  );

  test('consulta tickets por departamento con el contrato real', () async {
    RequestOptions? sentRequest;
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          sentRequest = options;
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              statusCode: 200,
              data: {
                'success': true,
                'message': 'Tickets del departamento obtenidos exitosamente',
                'data': [
                  {
                    'ticketId': 'ticket-2',
                    'title': 'Falla de red',
                    'description': 'No hay conexión',
                    'priority': 'Alta',
                    'status': 'Abierto',
                    'departmentId': 'dep-1',
                    'createdAtIso': '2026-10-28T12:00:00.000Z',
                    'authorName': 'María López',
                    'assignedToName': 'Sin asignar',
                  },
                ],
              },
            ),
          );
        },
      ),
    );

    final tickets = await TicketModel(client: dio)
        .getByDepartment('dep-1', 'jwt-test');

    expect(sentRequest?.method, 'GET');
    expect(sentRequest?.path, '/api/tickets/department?department_id=dep-1');
    expect(sentRequest?.headers['Authorization'], 'Bearer jwt-test');
    expect(tickets.single.ticketId, 'ticket-2');
    expect(tickets.single.authorName, 'María López');
    expect(tickets.single.assignedToName, 'Sin asignar');
  });

  test(
    'consulta y gestiona tickets con las rutas y cuerpos esperados',
    () async {
      final requests = <RequestOptions>[];
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
      final ticketData = {
        'ticketId': 'ticket-2',
        'title': 'Falla de red',
        'description': 'No hay conexión',
        'priority': 'Alta',
        'status': 'Abierto',
        'departmentId': 'dep-1',
        'createdById': 'user-1',
        'assignedToId': null,
        'authorName': 'María López',
        'assignedToName': 'Sin asignar',
      };
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requests.add(options);
            final data = switch (options.path) {
              '/api/tickets/mine' || '/api/tickets/pending' => [ticketData],
              '/api/tickets/ticket-2' => ticketData,
              '/api/users/solvers' => [
                {
                  'id': 'user-2',
                  'fullName': 'Juan Pérez',
                  'email': 'juan@test.com',
                },
              ],
              _ => <String, dynamic>{'id': 'ticket-2'},
            };
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 200,
                data: {'success': true, 'message': 'OK', 'data': data},
              ),
            );
          },
        ),
      );

      final model = TicketModel(client: dio);
      expect(
        (await model.getMyTickets('jwt-test')).single.ticketId,
        'ticket-2',
      );
      expect(
        (await model.getPendingTickets('jwt-test')).single.title,
        'Falla de red',
      );
      expect(
        (await model.getById('ticket-2', 'jwt-test')).createdById,
        'user-1',
      );
      expect(
        (await model.getAssignees('jwt-test')).single.fullName,
        'Juan Pérez',
      );
      await model.assign('ticket-2', 'user-2', 'jwt-test');
      await model.updateStatus('ticket-2', TicketStatus.enProgreso, 'jwt-test');

      expect(requests.map((request) => '${request.method} ${request.path}'), [
        'GET /api/tickets/mine',
        'GET /api/tickets/pending',
        'GET /api/tickets/ticket-2',
        'GET /api/users/solvers',
        'PATCH /api/tickets/ticket-2/assign',
        'PATCH /api/tickets/ticket-2/status',
      ]);
      expect(
        requests.every(
          (request) => request.headers['Authorization'] == 'Bearer jwt-test',
        ),
        isTrue,
      );
      expect(requests[4].data, {'assigned_to': 'user-2'});
      expect(requests[5].data, {'status': 'En progreso'});
    },
  );
}
