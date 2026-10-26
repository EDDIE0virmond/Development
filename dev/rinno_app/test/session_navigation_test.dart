import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:rinno_app/main.dart';
import 'package:rinno_app/core/network/app_api.dart';
import 'package:rinno_app/features/portal/client_home_page.dart';
import 'package:rinno_app/features/portal/card_detail_page.dart';
import 'app_api_test.dart' show MemoryStore, jsonResponse, session;

void main() {
  for (final event in ['revocation', 'logout', 'account change']) {
    testWidgets('$event clears private detail routes', (tester) async {
      var revoked = false;
      var secondUser = false;
      final store = MemoryStore();
      final api = AppApi(
        store: store,
        client: MockClient((request) async {
          if (request.url.path.endsWith('/login')) {
            final body = session('test-token');
            if (secondUser) (body['user'] as Map)['id'] = 'second-user';
            return jsonResponse(body);
          }
          if (revoked) return jsonResponse({'error': 'Access revoked'}, 403);
          return jsonResponse({'items': [], 'hasMore': false});
        }),
      );
      await api.login('audit@example.test', 'test-only-password');
      await tester.pumpWidget(MyApp(api: api));
      await tester.pumpAndSettle();
      openCardPage(
        tester.element(find.byType(ClientHomePage)),
        title: 'Private detail',
        builder: (_) => const Text('PRIVATE TEST DATA'),
      );
      await tester.pumpAndSettle();
      expect(find.text('PRIVATE TEST DATA'), findsOneWidget);
      if (event == 'revocation') {
        revoked = true;
        await expectLater(api.installations(), throwsA(isA<ApiException>()));
      } else if (event == 'logout') {
        await api.logout();
      } else {
        secondUser = true;
        await api.login('other@example.test', 'test-only-password');
      }
      await tester.pumpAndSettle();
      expect(find.text('PRIVATE TEST DATA', skipOffstage: false), findsNothing);
      expect(find.byTooltip('Voltar para a tela principal'), findsNothing);
      if (event != 'account change') {
        expect(api.user, isNull);
        expect(store.token, isNull);
        expect(find.byType(ClientHomePage), findsNothing);
      } else {
        expect(find.byType(ClientHomePage), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      api.dispose();
    });
  }
}
