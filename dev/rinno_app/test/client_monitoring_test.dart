import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:rinno_app/core/network/app_api.dart';
import 'package:rinno_app/features/portal/client_monitoring.dart';
import 'app_api_test.dart' show MemoryStore, jsonResponse, session;

void main() {
  testWidgets(
    'card loads generation and opens details without another request',
    (tester) async {
      var queries = 0;
      final api = AppApi(
        store: MemoryStore(),
        client: MockClient((request) async {
          if (request.url.path.endsWith('/login'))
            return jsonResponse(session('token'));
          if (request.url.path.endsWith('/insights')) {
            return jsonResponse({'series': [], 'timezone': 'America/Sao_Paulo'});
          }
          if (request.url.path.endsWith('/energy')) {
            queries++;
            return jsonResponse({
              'generationToday': 12.5,
              'generationMonth': 240.0,
              'consumptionToday': null,
              'consumptionMonth': null,
              'period': {'day': '2026-10-20', 'timezone': 'America/Sao_Paulo'},
            });
          }
          return jsonResponse({
            'items': [
              {
                'id': 'plant',
                'name': 'Usina do cliente',
                'provider': 'canadian',
              },
            ],
          });
        }),
      );
      await api.login('client@example.test', 'correct-password');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ClientMonitoring(api: api)),
        ),
      );
      await tester.pumpAndSettle();
      expect(queries, 1);
      expect(find.text('12,5 kWh'), findsOneWidget);
      expect(find.text('240,0 kWh'), findsOneWidget);
      await tester.tap(find.text('Ver gráficos e detalhes'));
      await tester.pumpAndSettle();
      expect(queries, 1);
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.text('Energia do dia'), findsOneWidget);
      expect(find.text('Energia do mês'), findsOneWidget);
      expect(find.text('Consumo: Não disponível'), findsNWidgets(2));
      await tester.tap(find.byTooltip('Fechar detalhes'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);      await tester.pumpWidget(const SizedBox());
      api.dispose();
    },
  );
}
