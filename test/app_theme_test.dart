import 'dart:io';
import 'dart:ui' as ui;

import 'package:centrix/app.dart';
import 'package:centrix/features/dashboard/views/dashboard_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'widget_test.dart' as fixtures;

const _captureKey = Key('unified-app-theme');
Future<void> _capture(WidgetTester tester, String name) async {
  final folder = Platform.environment['THEME_SCREENSHOTS'];
  if (folder == null) return;
  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(_captureKey),
    );
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await Directory(folder).create(recursive: true);
    await File('$folder/$name.png').writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  setUpAll(() async {
    final font = Platform.environment['THEME_VISUAL_FONT'];
    if (font != null) {
      final bytes = await File(font).readAsBytes();
      await (FontLoader(
        'Roboto',
      )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
      await (FontLoader(
        'MaterialIcons',
      )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    }
  });

  testWidgets(
    'formularios, listas, detalles y menús conservan el contexto oscuro',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        RepaintBoundary(
          key: _captureKey,
          child: CentrixApp(
            authModel: fixtures.FakeAuthModel(role: 'administrador'),
            departmentModel: fixtures.FakeDepartmentModel(),
            ticketModel: fixtures.FakeTicketModel(),
            userModel: fixtures.FakeUserModel(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        Theme.of(tester.element(find.byType(Scaffold).last)).brightness,
        Brightness.dark,
      );
      await _capture(tester, 'login-mobile');
      await fixtures.signIn(tester);
      final router = GoRouter.of(tester.element(find.byType(DashboardView)));
      for (final module in [
        'createTicket',
        'departments',
        'myTickets',
        'pendingTickets',
        'departmentTickets',
        'createUser',
      ]) {
        await fixtures.openModule(tester, module);
        expect(
          Theme.of(tester.element(find.byType(Scaffold).last)).brightness,
          Brightness.dark,
        );
        expect(tester.takeException(), isNull);
        await _capture(tester, '$module-mobile');
        if (module == 'pendingTickets') {
          await tester.tap(find.byKey(const Key('ticket-card-ticket-2')));
          await tester.pumpAndSettle();
          expect(find.text('Detalle del ticket'), findsOneWidget);
          await _capture(tester, 'ticket-detail-mobile');
        }
        if (module == 'createUser') {
          final roles = find.byKey(const ValueKey('user-role-colaborador'));
          await tester.ensureVisible(roles);
          await tester.tap(roles);
          await tester.pumpAndSettle();
          await _capture(tester, 'user-role-menu-mobile');
          await tester.tap(find.text('Gerente').last);
          await tester.pumpAndSettle();
        }
        router.go('/home');
        await tester.pumpAndSettle();
      }
    },
  );
}
