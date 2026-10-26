import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rinno_app/core/models/installation.dart';
import 'package:rinno_app/features/portal/completed_stages_timeline.dart';

InstallationStage stage(String name, String status) =>
    InstallationStage.fromJson({'id': name, 'nome': name, 'status': status});

void main() {
  testWidgets('full graph shows pending steps and forecasts without editing controls', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: CompletedStagesTimeline(stages: [
      stage('Primeira', 'concluida'),
      InstallationStage.fromJson({'id':'proxima','nome':'Próxima etapa','status':'pendente','previsao':'2026-11-15'}),
      stage('Última', 'pendente'),
    ])))));
    expect(find.text('Próxima etapa'), findsOneWidget);
    expect(find.text('Última'), findsOneWidget);
    expect(find.textContaining('15/11/2026'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    expect(find.byIcon(Icons.schedule_rounded), findsNWidgets(2));
    expect(find.byType(Checkbox), findsNothing);
    expect(find.byType(TextField), findsNothing);
    expect(tester.getTopLeft(find.text('Primeira')).dy, lessThan(tester.getTopLeft(find.text('Última')).dy));
    expect(tester.takeException(), isNull);
  });
  testWidgets('empty catalog has a helpful fallback', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: CompletedStagesTimeline(stages: []))));
    expect(find.text('O acompanhamento será disponibilizado em breve.'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsNothing);
  });
  for (final width in [320.0, 390.0, 768.0, 1280.0]) {
    testWidgets('branch graph is read-only and fits width $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final items =
          [
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
              ]
              .map(
                (s) => InstallationStage.fromJson({
                  'id': s[0],
                  'nome': s[0],
                  'branch': s[1],
                  'status': s[0]=='Contrato assinado'?'concluida':'pendente',
                  'previsao': '2026-11-15',
                }),
              )
              .toList();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: CompletedStagesTimeline(stages: items),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      expect(find.byType(Checkbox), findsNothing);
      expect(find.byIcon(Icons.schedule_rounded), findsNWidgets(9));
      expect(
        tester.getTopLeft(find.text('Solicitação de documentos')).dx,
        lessThan(tester.getTopLeft(find.text('Compra de material')).dx),
      );
      expect(
        tester.getBottomRight(find.text('Compra de material')).dx,
        lessThan(width),
      );
    });
  }
}
