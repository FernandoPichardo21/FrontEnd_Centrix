import 'dart:io';
import 'dart:ui' as ui;

import 'package:centrix/app.dart';
import 'package:centrix/features/auth/models/auth_user.dart';
import 'package:centrix/features/dashboard/models/dashboard_module.dart';
import 'package:centrix/features/dashboard/viewmodels/dashboard_view_model.dart';
import 'package:centrix/features/manager/models/manager_demo_model.dart';
import 'package:centrix/features/manager/models/manager_request.dart';
import 'package:centrix/features/manager/viewmodels/manager_view_model.dart';
import 'package:centrix/features/manager/views/manager_workspace_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

const captureKey = Key('manager-visual-capture');

Future<void> capture(WidgetTester tester, String name) async {
  final directory = Platform.environment['MANAGER_SCREENSHOTS'];
  if (directory == null) return;
  await tester.pumpAndSettle();
  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(captureKey),
    );
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final folder = Directory(directory);
    await folder.create(recursive: true);
    await File('${folder.path}/$name.png')
        .writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

Future<void> enterPreview(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    const RepaintBoundary(key: captureKey, child: CentrixApp()),
  );
  await tester.pumpAndSettle();
  final button = find.byKey(const Key('open-manager-preview'));
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    final font = Platform.environment['MANAGER_VISUAL_FONT'];
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

  test('Gerente recibe sus cuatro módulos y las decisiones son temporales y coherentes', () {
    const user = AuthUser(
      id: 'demo',
      email: 'demo@example.test',
      fullName: 'Gerente',
      role: 'gerente',
      roles: ['gerente'],
    );
    expect(
      DashboardViewModel(user).modules,
      containsAll([
        DashboardModule.managerApprovals,
        DashboardModule.managerBudget,
        DashboardModule.managerRequests,
        DashboardModule.managerReports,
      ]),
    );
    final vm = ManagerViewModel(ManagerDemoModel());
    final spent = vm.spent;
    final first = vm.pending.first;
    expect(
      vm.decide(first, ManagerRequestStatus.rejected, ''),
      contains('motivo'),
    );
    expect(vm.pending.length, 3);
    expect(
      vm.decide(first, ManagerRequestStatus.approved, 'Autorizado'),
      isNull,
    );
    expect(vm.spent, spent + first.amountCents);
    expect(vm.reportCount(ManagerRequestStatus.approved), 3);
    expect(vm.decide(first, ManagerRequestStatus.approved, ''), isNotNull);
    vm.search('Lucía');
    vm.filterStatus(ManagerRequestStatus.approved);
    expect(
      vm.filteredRequests.map((request) => request.id),
      contains(first.id),
    );
    expect(
      vm.filteredRequests.every(
        (request) => request.status == ManagerRequestStatus.approved,
      ),
      isTrue,
    );
    vm.reset();
    expect(vm.spent, spent);
    expect(vm.pending.length, 3);
    vm.dispose();
  });

  testWidgets(
    'vista previa de escritorio navega y comparte decisiones sin iniciar sesión',
    (tester) async {
      await enterPreview(tester, const Size(1440, 1100));
      expect(find.byType(ManagerWorkspaceView), findsOneWidget);
      expect(find.text('Decisiones que hacen avanzar.'), findsOneWidget);
      await capture(tester, 'desktop-aprobaciones');
      final vm = tester
          .element(find.byType(ManagerWorkspaceView))
          .read<ManagerViewModel>();
      final approve = find.byKey(const Key('approve-SOL-0418'));
      await tester.ensureVisible(approve);
      await tester.tap(approve);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm-manager-decision')));
      await tester.pumpAndSettle();
      expect(vm.pending.length, 2);
      for (final section in [
        ManagerSection.budget,
        ManagerSection.requests,
        ManagerSection.reports,
      ]) {
        await tester.tap(find.byKey(Key('manager-nav-${section.name}')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await capture(tester, 'desktop-${section.path}');
        if (section == ManagerSection.budget) {
          await tester.tap(find.byKey(const Key('adjust-manager-budget')));
          await tester.pumpAndSettle();
          await tester.enterText(
            find.byKey(const Key('budget-equipment')),
            '60000.00',
          );
          await tester.tap(find.byKey(const Key('save-manager-budget')));
          await tester.pumpAndSettle();
          expect(vm.budget, 13000000);
        }
        if (section == ManagerSection.requests) {
          final search = find.byKey(const ValueKey('manager-request-search-0'));
          await tester.enterText(search, 'SOL-0418');
          await tester.pumpAndSettle();
          expect(find.text('1 resultados'), findsOneWidget);
          await tester.enterText(search, '');
          await tester.pumpAndSettle();
        }
        expect(
          tester
              .element(find.byType(ManagerWorkspaceView))
              .read<ManagerViewModel>(),
          same(vm),
        );
      }
      await tester.tap(find.byKey(const Key('manager-report-month')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Octubre 2026').last);
      await tester.pumpAndSettle();
      expect(vm.reportRequests.length, 2);
      await tester.tap(find.byKey(const Key('exit-manager-preview')));
      await tester.pumpAndSettle();
      expect(find.text('Bienvenido de nuevo'), findsOneWidget);
    },
  );

  testWidgets(
    'las cuatro pantallas se adaptan al móvil con navegación lateral',
    (tester) async {
      await enterPreview(tester, const Size(390, 900));
      await capture(tester, 'mobile-aprobaciones');
      expect(tester.takeException(), isNull);
      for (final section in [
        ManagerSection.budget,
        ManagerSection.requests,
        ManagerSection.reports,
      ]) {
        await tester.tap(find.byTooltip('Open navigation menu'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(Key('manager-nav-${section.name}')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await capture(tester, 'mobile-${section.path}');
      }
    },
  );
}
