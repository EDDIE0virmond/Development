import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:rinno_app/core/network/app_api.dart';
import 'package:rinno_app/core/theme/app_theme.dart';
import 'package:rinno_app/core/theme/widgets/glass_surface.dart';
import 'package:rinno_app/features/portal/client_home_page.dart';
import 'app_api_test.dart' show MemoryStore, jsonResponse, session;

void main() {
  testWidgets(
    'mobile home preserves names, forecasts and graph before details',
    (tester) async {
      final font = Platform.environment['RINNO_PREVIEW_FONT'];
      if (font != null) {
        await tester.runAsync(() async {
          final loader = FontLoader('Roboto')
            ..addFont(
              File(
                font,
              ).readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
            );
          await loader.load();
          final icons = FontLoader('MaterialIcons')..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
          await icons.load();
        });
      }
      final steps = [
        ['Contrato assinado', 'root'],
        ['Solicitação de documentos', 'documents'],
        ['Assinatura de formulários', 'documents'],
        ['Projeto aprovado', 'documents'],
        ['Compra de material', 'installation'],
        ['Chegada de material', 'installation'],
        ['Agendamento da Instalação', 'installation'],
        ['Instalação', 'installation'],
        ['Vistoria Neoenergia', 'finish'],
        ['Sistema pronto', 'finish'],
      ];
      final api = AppApi(
        store: MemoryStore(),
        client: MockClient((request) async {
          if (request.url.path.endsWith('/login'))
            return jsonResponse(session('test'));
          if (request.url.path.endsWith('/stages'))
            return jsonResponse({
              'items': [
                for (final step in steps)
                  {
                    'id': step[0],
                    'nome': step[0],
                    'branch': step[1],
                    'status': step[1] == 'root' ? 'concluida' : 'pendente',
                    'previsao': '2026-11-15',
                    'dataConclusao': step[1] == 'root' ? '2026-10-26' : null,
                  },
              ],
            });
          if (request.url.path.endsWith('/monitoring'))
            return jsonResponse({'items': []});
          return jsonResponse({
            'items': [
              {
                'id': 'project',
                'codigo': 'SOL-2026-03577',
                'nome': 'Residência Jardim das Flores',
                'status': 'instalacao',
                'potenciaKwp': 8.4,
                'quantidadeModulos': 14,
              },
            ],
            'hasMore': false,
          });
        }),
      );
      await api.login('ana@example.test', 'password');
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final boundary = GlobalKey();
      for (final width in [320.0, 360.0, 390.0, 430.0]) {
        for (final scale in [1.0, 1.5, 2.0]) {
          tester.view.physicalSize = Size(width, 844);
          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.dark,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: RepaintBoundary(
                key: boundary,
                child: Scaffold(
                  body: PortalBackground(child: ClientHomePage(api: api)),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: '$width x $scale');
          expect(
            find.text('SOL-2026-03577 · Residência Jardim das Flores'),
            findsOneWidget,
          );
          expect(
            tester.getTopLeft(find.text('Sistema pronto')).dy,
            lessThan(tester.getTopLeft(find.text('Potência do sistema')).dy),
          );
          for (final step in steps) {
            final rect = tester.getRect(find.text(step[0]));
            expect(rect.left, greaterThanOrEqualTo(0));
            expect(rect.right, lessThanOrEqualTo(width));
          }
          expect(find.text('Previsão\n15/11/2026'), findsNWidgets(9));
        }
      }
      final output = Platform.environment['RINNO_PREVIEW_DIR'];
      if (output != null) {
        tester.view.physicalSize = const Size(390, 1800);
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.dark,
            home: RepaintBoundary(
              key: boundary,
              child: Scaffold(
                body: PortalBackground(child: ClientHomePage(api: api)),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          final context = boundary.currentContext!;
          await precacheImage(const AssetImage('assets/solar.png'), context);
          await precacheImage(const AssetImage('assets/rinnovare-wordmark.webp'), context);
        });
        await tester.pumpAndSettle();
        await Scrollable.ensureVisible(
          tester.element(find.text('Minhas instalações')),
          alignment: 0,
        );
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          final image =
              await (boundary.currentContext!.findRenderObject()
                      as RenderRepaintBoundary)
                  .toImage(pixelRatio: 1);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(
            '$output/app-mobile-graph-preview.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
      await tester.pumpWidget(const SizedBox());
      api.dispose();
    },
  );
}
