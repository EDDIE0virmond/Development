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
          if (request.url.path.endsWith('/stages')) return jsonResponse({'items':[{'id':'contrato','nome':'Contrato assinado','branch':'root','status':'pendente','previsao':'2026-11-15'}]});
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
          greaterThan(tester.getBottomLeft(find.text('Detalhes e documentos')).dy),
        );
      }
      expect(find.text('Contrato assinado'), findsOneWidget);
      expect(find.textContaining('15/11/2026'), findsOneWidget);
      expect(energyCalls, linked ? 1 : 0);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Detalhes e documentos'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
      expect(find.text('Minha instalação'), findsOneWidget);
      for (final size in [
        const Size(320, 640),
        const Size(390, 844),
        const Size(430, 932),
        const Size(768, 1024),
        const Size(844, 390),
        const Size(1440, 900),
      ]) {
        tester.view.physicalSize = size;
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'Installation $size');
      }
      await tester.tap(find.byTooltip('Voltar para a tela principal'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
      await tester.pumpWidget(const SizedBox());
      api.dispose();
    });
  }
}
