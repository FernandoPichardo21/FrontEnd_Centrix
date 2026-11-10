import 'package:centrix/app.dart';
import 'package:centrix/features/admin_users/models/create_user_request.dart';
import 'package:centrix/features/admin_users/models/created_user.dart';
import 'package:centrix/features/admin_users/models/user_model.dart';
import 'package:centrix/features/auth/models/auth_model.dart';
import 'package:centrix/features/auth/models/auth_session.dart';
import 'package:centrix/features/auth/models/auth_user.dart';
import 'package:centrix/features/departments/models/department.dart';
import 'package:centrix/features/departments/models/department_model.dart';
import 'package:centrix/features/tickets/models/create_ticket_request.dart';
import 'package:centrix/features/tickets/models/created_ticket.dart';
import 'package:centrix/features/tickets/models/ticket.dart';
import 'package:centrix/features/tickets/models/ticket_assignee.dart';
import 'package:centrix/features/tickets/models/ticket_model.dart';
import 'package:centrix/features/tickets/models/ticket_status.dart';
import 'package:centrix/features/tickets/models/ticket_evidence.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAuthModel extends AuthModel {
  FakeAuthModel({this.role = 'colaborador'});

  final String role;

  @override
  Future<AuthSession> login(String email, String password) async {
    return AuthSession(
      user: AuthUser(
        id: 'user-1',
        email: email,
        fullName: 'María López',
        role: role,
        roles: [role],
      ),
      token: 'test-token',
    );
  }
}

class FakeDepartmentModel extends DepartmentModel {
  String? receivedToken;

  @override
  Future<List<Department>> fetchAll(String token) async {
    receivedToken = token;
    return const [
      Department(
        departmentId: 'dep-1',
        name: 'Soporte TI',
        description: 'Atención a equipos de cómputo',
      ),
    ];
  }
}

class FakeTicketModel extends TicketModel {
  CreateTicketRequest? receivedRequest;
  String? receivedToken;
  String? receivedDepartmentId;
  String? assignedUserId;
  TicketStatus? savedStatus;
  String? currentAssigneeId;
  String currentStatus = 'Abierto';

  Ticket get currentTicket => Ticket(
    ticketId: 'ticket-2',
    title: 'Falla de red',
    description: 'No hay conexión',
    priority: 'Alta',
    status: currentStatus,
    departmentId: 'dep-1',
    createdById: 'user-1',
    assignedToId: currentAssigneeId,
    authorName: 'María López',
    assignedToName: currentAssigneeId == null ? 'Sin asignar' : 'Juan Pérez',
  );

  @override
  Future<List<Ticket>> getMyTickets(String token) async => [currentTicket];

  @override
  Future<List<Ticket>> getPendingTickets(String token) async => [currentTicket];

  @override
  Future<Ticket> getById(String ticketId, String token) async => currentTicket;

  @override
  Future<List<TicketEvidence>> getEvidences(
    String ticketId,
    String token,
  ) async => const [];

  @override
  Future<List<TicketAssignee>> getAssignees(String token, {String? departmentId}) async => const [
    TicketAssignee(
      id: 'user-2',
      fullName: 'Juan Pérez',
      email: 'juan@test.com',
    ),
  ];

  @override
  Future<void> assign(String ticketId, String assigneeId, String token) async {
    assignedUserId = assigneeId;
    currentAssigneeId = assigneeId;
  }

  @override
  Future<void> updateStatus(
    String ticketId,
    TicketStatus status,
    String token,
  ) async {
    savedStatus = status;
    currentStatus = status.apiValue;
  }

  @override
  Future<CreatedTicket> create(
    CreateTicketRequest request,
    String token,
  ) async {
    receivedRequest = request;
    receivedToken = token;
    return const CreatedTicket(id: 'ticket-1');
  }

  @override
  Future<List<Ticket>> getByDepartment(
    String departmentId,
    String token,
  ) async {
    receivedDepartmentId = departmentId;
    receivedToken = token;
    return const [
      Ticket(
        ticketId: 'ticket-2',
        title: 'Falla de red',
        description: 'No hay conexión',
        priority: 'Alta',
        status: 'Abierto',
        departmentId: 'dep-1',
        authorName: 'María López',
        assignedToName: 'Sin asignar',
      ),
    ];
  }
}

class FakeUserModel extends UserModel {
  CreateUserRequest? receivedRequest;
  String? receivedToken;

  @override
  Future<CreatedUser> create(CreateUserRequest request, String token) async {
    receivedRequest = request;
    receivedToken = token;
    return const CreatedUser(id: 'user-2');
  }
}

Future<void> signIn(WidgetTester tester) async {
  await tester.enterText(find.byKey(const Key('email')), 'maria@empresa.com');
  await tester.enterText(find.byKey(const Key('password')), 'clave123');
  final button = find.widgetWithText(FilledButton, 'Iniciar sesión');
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}

Future<void> openModule(WidgetTester tester, String moduleName) async {
  final module = find.byKey(Key('module-$moduleName'));
  await tester.scrollUntilVisible(
    module,
    250,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(module);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('El login valida y abre el inicio al autenticar', (tester) async {
    final departmentModel = FakeDepartmentModel();
    await tester.pumpWidget(
      CentrixApp(authModel: FakeAuthModel(), departmentModel: departmentModel),
    );
    await tester.pumpAndSettle();

    final button = find.widgetWithText(FilledButton, 'Iniciar sesión');
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pump();
    expect(find.text('Ingresa un correo válido'), findsOneWidget);
    expect(find.text('Ingresa tu contraseña'), findsOneWidget);

    await signIn(tester);

    expect(find.text('Hola, María López'), findsOneWidget);
    expect(find.text('Colaborador'), findsOneWidget);
    expect(find.byKey(const Key('module-createTicket')), findsOneWidget);
    expect(find.byKey(const Key('module-departments')), findsOneWidget);
    expect(find.byKey(const Key('module-createUser')), findsNothing);

    await openModule(tester, 'departments');
    expect(find.text('Catálogo de departamentos'), findsOneWidget);
    expect(find.text('Soporte TI'), findsOneWidget);
    expect(departmentModel.receivedToken, 'test-token');
  });

  testWidgets('un colaborador puede crear un ticket', (tester) async {
    final ticketModel = FakeTicketModel();
    await tester.pumpWidget(
      CentrixApp(
        authModel: FakeAuthModel(),
        departmentModel: FakeDepartmentModel(),
        ticketModel: ticketModel,
      ),
    );
    await tester.pumpAndSettle();
    await signIn(tester);

    await openModule(tester, 'createTicket');

    await tester.enterText(
      find.byKey(const Key('ticket-title')),
      'Falla de equipo',
    );
    await tester.enterText(
      find.byKey(const Key('ticket-description')),
      'No enciende',
    );
    await tester.ensureVisible(find.byKey(const Key('ticket-priority')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ticket-priority')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Alta').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('ticket-department')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ticket-department')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Soporte TI').last);
    await tester.pumpAndSettle();

    final submitButton = find.widgetWithText(FilledButton, 'Crear ticket');
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(find.text('Ticket creado'), findsOneWidget);
    expect(find.text('ID del ticket: ticket-1'), findsOneWidget);
    expect(ticketModel.receivedRequest?.departmentId, 'dep-1');
    expect(ticketModel.receivedToken, 'test-token');
  });

  testWidgets('un gerente ve los tickets de un departamento', (tester) async {
    final ticketModel = FakeTicketModel();
    await tester.pumpWidget(
      CentrixApp(
        authModel: FakeAuthModel(role: 'gerente'),
        departmentModel: FakeDepartmentModel(),
        ticketModel: ticketModel,
      ),
    );
    await tester.pumpAndSettle();
    await signIn(tester);

    await openModule(tester, 'departmentTickets');

    expect(find.text('Consulta de incidencias'), findsOneWidget);
    expect(find.text('Falla de red'), findsOneWidget);
    expect(find.text('Reportado por: María López'), findsOneWidget);
    expect(ticketModel.receivedDepartmentId, 'dep-1');
    expect(ticketModel.receivedToken, 'test-token');
  });

  testWidgets('un administrador puede crear un usuario', (tester) async {
    final userModel = FakeUserModel();
    await tester.pumpWidget(
      CentrixApp(
        authModel: FakeAuthModel(role: 'administrador'),
        userModel: userModel,
      ),
    );
    await tester.pumpAndSettle();
    await signIn(tester);

    await openModule(tester, 'createUser');

    await tester.enterText(
      find.byKey(const Key('user-email')),
      'nueva@empresa.com',
    );
    await tester.enterText(find.byKey(const Key('user-name')), 'Ana');
    await tester.enterText(find.byKey(const Key('user-last-name')), 'López');
    await tester.enterText(
      find.byKey(const Key('user-password')),
      'claveSegura123',
    );
    await tester.enterText(
      find.byKey(const Key('user-confirm-password')),
      'claveSegura123',
    );

    final submitButton = find.widgetWithText(FilledButton, 'Crear usuario');
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(find.text('Usuario creado'), findsOneWidget);
    expect(find.text('ID del usuario: user-2'), findsOneWidget);
    expect(userModel.receivedRequest?.email, 'nueva@empresa.com');
    expect(userModel.receivedToken, 'test-token');
  });

  testWidgets('un gerente abre un pendiente, lo asigna y cambia su estado', (
    tester,
  ) async {
    final ticketModel = FakeTicketModel();
    await tester.pumpWidget(
      CentrixApp(
        authModel: FakeAuthModel(role: 'gerente'),
        ticketModel: ticketModel,
      ),
    );
    await tester.pumpAndSettle();
    await signIn(tester);
    await openModule(tester, 'pendingTickets');

    await tester.tap(find.byKey(const Key('ticket-card-ticket-2')));
    await tester.pumpAndSettle();
    expect(find.text('Detalle del ticket'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('ticket-assignee')),
      220,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ticket-assignee')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Juan Pérez (juan@test.com)').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('assign-ticket')),
      180,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('assign-ticket')));
    await tester.pumpAndSettle();
    expect(ticketModel.assignedUserId, 'user-2');

    await tester.scrollUntilVisible(
      find.byKey(const Key('ticket-status')),
      180,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ticket-status')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('En progreso').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('save-ticket-status')),
      180,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('save-ticket-status')));
    await tester.pumpAndSettle();
    expect(ticketModel.savedStatus, TicketStatus.enProgreso);
    expect(find.text('Estado actualizado.'), findsOneWidget);
  });
}
