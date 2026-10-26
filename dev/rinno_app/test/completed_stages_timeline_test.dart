import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rinno_app/core/models/installation.dart';
import 'package:rinno_app/features/portal/completed_stages_timeline.dart';

InstallationStage stage(String name, String status) =>
    InstallationStage.fromJson({'id': name, 'nome': name, 'status': status});

void main() {
  testWidgets('only completed stages appear, preserving workflow order', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CompletedStagesTimeline(
            stages: [
              stage('Primeira', 'concluida'),
              stage('Pendente secreta', 'pendente'),
              stage('Em andamento secreta', 'em_andamento'),
              stage('Última', 'concluida'),
              stage('Bloqueada secreta', 'bloqueada'),
            ],
          ),
        ),
      ),
    );
    expect(find.textContaining('secreta'), findsNothing);
    expect(find.byIcon(Icons.check_rounded), findsNWidgets(2));
    expect(
      tester.getTopLeft(find.text('Primeira')).dy,
      lessThan(tester.getTopLeft(find.text('Última')).dy),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty history does not disclose future stages', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CompletedStagesTimeline(stages: [stage('Futura', 'pendente')]),
        ),
      ),
    );
    expect(find.text('Futura'), findsNothing);
    expect(find.text('As etapas concluídas aparecerão aqui.'), findsOneWidget);
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
                ['Agendamento', 'installation'],
                ['Instalação', 'installation'],
                ['Vistoria Neoenergia', 'finish'],
                ['Sistema pronto', 'finish'],
              ]
              .map(
                (s) => InstallationStage.fromJson({
                  'id': s[0],
                  'nome': s[0],
                  'branch': s[1],
                  'status': 'concluida',
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
      expect(find.byIcon(Icons.check_rounded), findsNWidgets(10));
      expect(find.byType(Checkbox), findsNothing);
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
