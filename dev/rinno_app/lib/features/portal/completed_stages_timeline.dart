import 'package:flutter/material.dart';
import '../../core/models/installation.dart';
import '../../core/theme/app_theme.dart';

/// Read-only graph; future milestones remain undisclosed in the customer app.
class CompletedStagesTimeline extends StatelessWidget {
  final List<InstallationStage> stages;
  const CompletedStagesTimeline({super.key, required this.stages});
  @override
  Widget build(BuildContext context) {
    final completed = stages.where((s) => s.completed).toList();
    if (completed.isEmpty)
      return const Text('As etapas concluídas aparecerão aqui.');
    final roots = completed.where((s) => s.branch == 'root').toList();
    final left = completed.where((s) => s.branch == 'documents').toList();
    final right = completed.where((s) => s.branch == 'installation').toList();
    final finish = completed.where((s) => s.branch == 'finish').toList();
    final branches = left.isNotEmpty || right.isNotEmpty;
    Widget chain(List<InstallationStage> items) => Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const _Line(),
          _Node(stage: items[i]),
        ],
      ],
    );
    return Column(
      children: [
        if (roots.isNotEmpty) chain(roots),
        if (branches) ...[
          if (roots.isNotEmpty)
            _Junction(left: left.isNotEmpty, right: right.isNotEmpty),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      chain(left),
                      if (left.isNotEmpty && finish.isNotEmpty)
                        Expanded(
                          child: Container(width: 2, color: AppTheme.lime),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      chain(right),
                      if (right.isNotEmpty && finish.isNotEmpty)
                        Expanded(
                          child: Container(width: 2, color: AppTheme.lime),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (finish.isNotEmpty)
            _Junction(
              left: left.isNotEmpty,
              right: right.isNotEmpty,
              merge: true,
            ),
        ] else if (roots.isNotEmpty && finish.isNotEmpty)
          const _Line(),
        if (finish.isNotEmpty) chain(finish),
      ],
    );
  }
}

class _Node extends StatelessWidget {
  final InstallationStage stage;
  const _Node({required this.stage});
  @override
  Widget build(BuildContext context) => Semantics(
    label: '${stage.nome}, concluída',
    excludeSemantics: true,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.navy.withValues(alpha: .70),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.lime.withValues(alpha: .5)),
      ),
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.lime,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lime.withValues(alpha: .18),
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppTheme.navy,
              size: 26,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            stage.nome,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (stage.dataConclusao != null) ...[
            const SizedBox(height: 5),
            Text(
              MaterialLocalizations.of(
                context,
              ).formatCompactDate(stage.dataConclusao!),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xffd2e3e0), fontSize: 12),
            ),
          ],
        ],
      ),
    ),
  );
}

class _Line extends StatelessWidget {
  const _Line();
  @override
  Widget build(BuildContext context) =>
      Container(width: 2, height: 24, color: AppTheme.lime);
}

class _Junction extends StatelessWidget {
  final bool left, right, merge;
  const _Junction({
    required this.left,
    required this.right,
    this.merge = false,
  });
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 32,
    width: double.infinity,
    child: CustomPaint(painter: _JunctionPainter(left, right, merge)),
  );
}

class _JunctionPainter extends CustomPainter {
  final bool left, right, merge;
  _JunctionPainter(this.left, this.right, this.merge);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.lime
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final center = size.width / 2;
    final top = merge ? size.height : 0.0;
    final bottom = merge ? 0.0 : size.height;
    final mid = size.height / 2;
    canvas.drawLine(Offset(center, top), Offset(center, mid), paint);
    for (final x in [
      if (left) (size.width - 16) / 4,
      if (right) size.width - (size.width - 16) / 4,
    ]) {
      canvas.drawPath(
        Path()
          ..moveTo(center, mid)
          ..lineTo(x, mid)
          ..lineTo(x, bottom),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_JunctionPainter old) =>
      left != old.left || right != old.right || merge != old.merge;
}
