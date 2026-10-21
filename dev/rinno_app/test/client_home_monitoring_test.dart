import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:rinno_app/core/network/app_api.dart';
import 'package:rinno_app/features/portal/client_home_page.dart';
import 'app_api_test.dart' show MemoryStore, jsonResponse, session;

void main() {
  for (final linked in [false, true]) {
    testWidgets('home shows monitoring only when linked: $linked', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var energyCalls = 0;
      final api = AppApi(
        store: MemoryStore(),
        client: MockClient((request) async {
          if (request.url.path.endsWith('/login'))
            return jsonResponse(session('token'));
          if (request.url.path.endsWith('/energy')) energyCalls++;
          if (request.url.path.endsWith('/monitoring')) {
            return jsonResponse({
              'items': linked
                  ? [
                      {
                        'id': 'plant',
                        'name': 'Usina vinculada',
                        'provider': 'solis',
                      },
                    ]
                  : [],
            });
          }
          return jsonResponse({
            'items': [
              {
                'id': 'installation',
                'codigo': 'SOL-001',
                'status': 'instalacao',
              },
            ],
            'hasMore': false,
          });
        }),
      );
      await api.login('client@example.test', 'password');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ClientHomePage(api: api)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('SEU PORTAL'), findsNothing);
      expect(find.byType(ChoiceChip), findsNothing);
      expect(
        find.text('Monitoramento'),
        linked ? findsOneWidget : findsNothing,
      );
      if (linked) {
        expect(
          tester.getTopLeft(find.text('Monitoramento')).dy,
          greaterThan(tester.getBottomLeft(find.text('Ver instalação')).dy),
        );
      }
      expect(energyCalls, linked ? 1 : 0);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      api.dispose();
    });
  }
}
