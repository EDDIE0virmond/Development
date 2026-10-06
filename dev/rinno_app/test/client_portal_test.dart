import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:rinno_app/main.dart';
import 'package:rinno_app/core/network/app_api.dart';
import 'package:rinno_app/features/portal/client_portal.dart';
import 'app_api_test.dart' show MemoryStore, jsonResponse, session;

void main() {
  testWidgets(
    'recovery site opens email recovery without restoring a session',
    (tester) async {
      var requests = 0;
      final store = MemoryStore();
      final api = AppApi(
        store: store,
        client: MockClient((r) async {
          requests++;
          expect(r.url.path.endsWith('/auth/recover'), isTrue);
          return jsonResponse({});
        }),
      );
      await tester.pumpWidget(
        MaterialApp(home: ClientPortal(api: api, recoveryOnly: true)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Vamos recuperar seu acesso.'), findsOneWidget);
      expect(find.text('Senha'), findsNothing);
      expect(find.text('Voltar ao aplicativo'), findsOneWidget);
      expect(find.text('Voltar para entrar'), findsNothing);
      expect(requests, 0);
      await tester.enterText(find.byType(TextFormField), 'ana@example.test');
      await tester.ensureVisible(find.text('Enviar instruções'));
      await tester.tap(find.text('Enviar instruções'));
      await tester.pumpAndSettle();
      expect(requests, 1);
      expect(
        find.textContaining('você receberá as instruções'),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox());
      api.dispose();
    },
  );
  testWidgets('client can open installation stages and published documents', (
    tester,
  ) async {
    final api = AppApi(
      store: MemoryStore(),
      client: MockClient((r) async {
        if (r.url.path.endsWith('/login')) {
          return jsonResponse(session('token'));
        }
        if (r.url.path.endsWith('/stages')) {
          return jsonResponse({
            'items': [
              {
                'id': 'stage',
                'nome': 'Instalação dos módulos',
                'status': 'concluida',
                'dataConclusao': '2026-10-01',
              },
            ],
          });
        }
        if (r.url.path.endsWith('/documents')) {
          return jsonResponse({
            'items': [
              {
                'id': 'document',
                'nome': 'Manual do sistema.pdf',
                'tipo': 'manual',
              },
            ],
          });
        }
        final installation = {
          'id': '20000000-0000-4000-8000-000000000001',
          'codigo': 'SOL-001',
          'status': 'instalacao',
          'potenciaKwp': 6.5,
          'quantidadeModulos': 12,
        };
        return jsonResponse(
          r.url.path.endsWith('/installations')
              ? {
                  'items': [installation],
                  'hasMore': false,
                }
              : installation,
        );
      }),
    );
    await api.login('ana@example.test', 'password');
    await tester.pumpWidget(MyApp(api: api));
    await tester.pumpAndSettle();
    expect(find.text('SOL-001'), findsOneWidget);
    await tester.ensureVisible(find.text('Ver instalação'));
    await tester.tap(find.text('Ver instalação'));
    await tester.pumpAndSettle();
    expect(find.text('Instalação dos módulos'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Manual do sistema.pdf'), 300);
    expect(find.text('Manual do sistema.pdf'), findsOneWidget);
    expect(find.text('Excluir'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    api.dispose();
  });
  testWidgets('failed list offers retry instead of an empty success', (
    tester,
  ) async {
    final api = AppApi(
      store: MemoryStore(),
      client: MockClient(
        (r) async => r.url.path.endsWith('/login')
            ? jsonResponse(session('token'))
            : jsonResponse({'error': 'Serviço indisponível'}, 503),
      ),
    );
    await api.login('ana@example.test', 'password');
    await tester.pumpWidget(MyApp(api: api));
    await tester.pumpAndSettle();
    expect(find.text('Tentar novamente'), findsOneWidget);
    expect(find.text('Nenhuma instalação por aqui ainda'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    api.dispose();
  });
}
