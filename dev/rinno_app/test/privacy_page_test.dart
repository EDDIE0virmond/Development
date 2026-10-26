import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:rinno_app/core/network/app_api.dart';
import 'package:rinno_app/core/theme/app_theme.dart';
import 'package:rinno_app/features/portal/client_portal.dart';
import 'package:rinno_app/features/portal/privacy_page.dart';
import 'app_api_test.dart' show MemoryStore, jsonResponse;

void main() {
  testWidgets('privacy is accessible before login and returns to the login', (
    tester,
  ) async {
    final api = AppApi(
      store: MemoryStore(),
      client: MockClient(
        (_) async => jsonResponse({'error': 'No session'}, 401),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: ClientPortal(api: api),
      ),
    );
    await tester.pumpAndSettle();
    final link = find.widgetWithText(TextButton, 'Privacidade e dados');
    await tester.ensureVisible(link);
    await tester.tap(link);
    await tester.pumpAndSettle();
    expect(find.byType(PrivacyPage), findsOneWidget);
    expect(find.text('Quem cuida do acesso'), findsOneWidget);
    await tester.tap(find.byTooltip('Voltar para a tela principal'));
    await tester.pumpAndSettle();
    expect(find.byType(PrivacyPage), findsNothing);
    expect(api.user, isNull);
    await tester.pumpWidget(const SizedBox());
    api.dispose();
  });

  testWidgets('privacy remains readable on a narrow phone with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: const Scaffold(body: PrivacyPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.text('Solicitar ajuda ou exclusão de dados'),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
