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
}
