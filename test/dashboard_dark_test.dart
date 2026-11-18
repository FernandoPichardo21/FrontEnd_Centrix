import 'dart:io';
import 'dart:ui' as ui;

import 'package:centrix/app.dart';
import 'package:centrix/features/auth/models/auth_model.dart';
import 'package:centrix/features/auth/models/auth_session.dart';
import 'package:centrix/features/auth/models/auth_user.dart';
import 'package:centrix/features/dashboard/models/dashboard_module.dart';
import 'package:centrix/features/dashboard/viewmodels/dashboard_view_model.dart';
import 'package:centrix/features/dashboard/views/dashboard_view.dart';
import 'package:centrix/features/departments/models/department.dart';
import 'package:centrix/features/departments/models/department_model.dart';
import 'package:centrix/features/tickets/models/ticket.dart';
import 'package:centrix/features/tickets/models/ticket_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class DashboardAuthFixture extends AuthModel {
  @override
  Future<AuthSession> login(String email, String password) async =>
      const AuthSession(
        user: AuthUser(
          id: 'test-user',
          email: 'miguel@centrix.test',
          fullName: 'Miguel Ángel Durazno',
          role: 'administrador',
          roles: ['administrador'],
        ),
        token: 'test-token',
      );
}

class DashboardTicketFixture extends TicketModel {
  Ticket ticket(int index, {bool pending = false}) => Ticket(
    ticketId: '${pending ? 'pending' : 'mine'}-$index',
    title: pending ? 'Revisión de equipo $index' : 'Seguimiento de red $index',
    description: 'Datos de prueba',
    priority: 'Alta',
    status: !pending && index < 2 ? 'Cerrado' : 'En progreso',
    departmentId: 'dept-1',
    authorName: 'Miguel',
    assignedToName: 'Equipo de soporte',
    createdAtIso: DateTime(2026, 11, 11, 12, index).toIso8601String(),
  );
  @override
  Future<List<Ticket>> getMyTickets(String token) async =>
      List.generate(8, (i) => ticket(i));
  @override
  Future<List<Ticket>> getPendingTickets(String token) async =>
      List.generate(15, (i) => ticket(i, pending: true));
}

class DashboardDepartmentFixture extends DepartmentModel {
  @override
  Future<List<Department>> fetchAll(String token) async => List.generate(
    6,
    (i) => Department(departmentId: 'dept-$i', name: 'Área $i'),
  );
}

const captureKey = Key('dashboard-dark-capture');
Future<void> screenshot(WidgetTester tester, String name) async {
  final folder = Platform.environment['DASHBOARD_SCREENSHOTS'];
  if (folder == null) return;
  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(captureKey),
    );
    final image = await boundary.toImage(pixelRatio: 1);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    await Directory(folder).create(recursive: true);
    await File('$folder/$name.png').writeAsBytes(data!.buffer.asUint8List());
    image.dispose();
  });
}

Future<void> openDashboard(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    RepaintBoundary(
      key: captureKey,
      child: CentrixApp(
        authModel: DashboardAuthFixture(),
        departmentModel: DashboardDepartmentFixture(),
        ticketModel: DashboardTicketFixture(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(const Key('email')), 'admin@centrix.test');
  await tester.enterText(find.byKey(const Key('password')), 'test-password');
  final login = find.widgetWithText(FilledButton, 'Iniciar sesión');
  await tester.ensureVisible(login);
  await tester.tap(login);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    final font = Platform.environment['DASHBOARD_VISUAL_FONT'];
    if (font != null) {
      final data = await File(font).readAsBytes();
      await (FontLoader(
        'Roboto',
      )..addFont(Future.value(ByteData.sublistView(data)))).load();
      await (FontLoader(
        'MaterialIcons',
      )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    }
  });

  testWidgets(
    'dashboard móvil cabe en una pantalla y usa contadores consultados',
    (tester) async {
      await openDashboard(tester, const Size(390, 844));
      expect(find.text('¡Hola, Miguel!'), findsOneWidget);
      final vm = tester
          .element(find.byType(DashboardView))
          .read<DashboardViewModel>();
      expect(vm.badge(DashboardModule.myTickets), '08');
      expect(vm.badge(DashboardModule.pendingTickets), '15');
      expect(vm.badge(DashboardModule.departments), '06');
      expect(vm.resolutionRate, .25);
      final scroll = find
          .descendant(
            of: find.byKey(const Key('dashboard-body-scroll')),
            matching: find.byType(Scrollable),
          )
          .first;
      expect(
        tester.state<ScrollableState>(scroll).position.maxScrollExtent,
        lessThanOrEqualTo(1),
      );
      expect(tester.takeException(), isNull);
      await screenshot(tester, 'dashboard-mobile');
      await tester.tap(find.text('Mensajes'));
      await tester.pumpAndSettle();
      expect(find.text('Vista previa'), findsOneWidget);
      await tester.tapAt(const Offset(10, 100));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('dashboard-profile')));
      await tester.pumpAndSettle();
      expect(find.text('Cerrar sesión'), findsOneWidget);
    },
  );

  testWidgets('escritorio conserva el acceso a todos los módulos del rol', (
    tester,
  ) async {
    await openDashboard(tester, const Size(1440, 1000));
    expect(tester.takeException(), isNull);
    await screenshot(tester, 'dashboard-desktop');
    await tester.tap(find.byKey(const Key('dashboard-all-modules')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('all-module-departmentTickets')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('all-module-createUser')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
