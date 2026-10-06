import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:rinno_app/main.dart';
import 'package:rinno_app/core/network/app_api.dart';
import 'app_api_test.dart' show MemoryStore;

void main() {
  testWidgets('small screen and large text retain accessible client login', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final api = AppApi(
      client: MockClient((_) async => http.Response('{}', 401)),
      store: MemoryStore(),
    );
    await tester.pumpWidget(MyApp(api: api));
    await tester.pumpAndSettle();
    expect(find.text('Bem-vindo à sua energia.'), findsOneWidget);
    expect(find.text('Criar conta'), findsNothing);
    expect(find.text('Gerenciar usuários'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    api.dispose();
  });
}
