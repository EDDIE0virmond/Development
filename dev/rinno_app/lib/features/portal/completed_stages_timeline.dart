import 'package:flutter/material.dart';
import '../../core/models/installation.dart';

const _accent = Color(0xff9adea9);
const _connector = Color(0xff80bca0);

/// Customer milestones remain read-only; pending milestones are never rendered.
class CompletedStagesTimeline extends StatelessWidget {
  final List<InstallationStage> stages;
  const CompletedStagesTimeline({super.key, required this.stages});
  @override
  Widget build(BuildContext context) {
    final completed = stages.where((s) => s.completed).toList();
    if (completed.isEmpty) {
      return Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .07),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.route_rounded, color: _accent, size: 22),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seu acompanhamento',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'As etapas concluídas aparecerão aqui.',
                  style: TextStyle(
                    color: Color(0xffc3d1db),
                    height: 1.5,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
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
    Widget centerChain(List<InstallationStage> items) => Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: FractionallySizedBox(widthFactor: .92, child: chain(items)),
      ),
    );
    Widget branchChain(List<InstallationStage> items) => Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          _Node(stage: items[i]),
          if (i < items.length - 1)
            Expanded(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: 26),
                child: _Stem(),
              ),
            ),
        ],
      ],
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Column(
          children: [
            if (roots.isNotEmpty) centerChain(roots),
            if (branches) ...[
              if (left.isNotEmpty && right.isNotEmpty) ...[
                if (roots.isNotEmpty) const _Junction(left: true, right: true),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: branchChain(left)),
                      const SizedBox(width: 20),
                      Expanded(child: branchChain(right)),
                    ],
                  ),
                ),
                if (finish.isNotEmpty)
                  const _Junction(left: true, right: true, merge: true),
              ] else ...[
                if (roots.isNotEmpty) const _Line(),
                centerChain(left.isNotEmpty ? left : right),
                if (finish.isNotEmpty) const _Line(),
              ],
            ] else if (roots.isNotEmpty && finish.isNotEmpty)
              const _Line(),
            if (finish.isNotEmpty) centerChain(finish),
          ],
        ),
      ),
    );
  }
}

class _Node extends StatelessWidget {
  final InstallationStage stage;
  const _Node({required this.stage});
  @override
  Widget build(BuildContext context) {
    final date = stage.dataConclusao?.toLocal();
    final dateLabel = date == null
        ? 'Concluída'
        : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    return Semantics(
      label: '${stage.nome}, concluída, $dateLabel',
      excludeSemantics: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xff263e51), Color(0xff1c2d42)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: .17)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14040e20),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Builder(
          builder: (context) {
            final compact = MediaQuery.sizeOf(context).width < 700;
            final check = Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xffb1edb4), Color(0xff78c99a)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _accent.withValues(alpha: .08),
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Color(0xff163d32),
                size: 20,
              ),
            );
            final words = Column(
              crossAxisAlignment: compact
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  stage.nome,
                  textAlign: compact ? TextAlign.center : TextAlign.left,
                  style: const TextStyle(
                    color: Color(0xfff5fafc),
                    fontSize: 13,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  dateLabel,
                  textAlign: compact ? TextAlign.center : TextAlign.left,
                  style: const TextStyle(
                    color: Color(0xffb9cbd6),
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            );
            return compact
                ? Column(children: [check, const SizedBox(height: 12), words])
                : Row(
                    children: [
                      check,
                      const SizedBox(width: 14),
                      Expanded(child: words),
                    ],
                  );
          },
        ),
      ),
    );
  }
}

class _Stem extends StatelessWidget {
  const _Stem();
  @override
  Widget build(BuildContext context) =>
      Center(child: Container(width: 1.5, color: _connector));
}

class _Line extends StatelessWidget {
  const _Line();
  @override
  Widget build(BuildContext context) =>
      const SizedBox(height: 26, child: _Stem());
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
    height: 42,
    width: double.infinity,
    child: CustomPaint(painter: _JunctionPainter(left, right, merge)),
  );
}

class _JunctionPainter extends CustomPainter {
  final bool left, right, merge;
  _JunctionPainter(this.left, this.right, this.merge);
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.width / 2;
    final paths = <Path>[];
    for (final x in [
      if (left) (size.width - 20) / 4,
      if (right) size.width - (size.width - 20) / 4,
    ]) {
      final start = merge ? x : center, end = merge ? center : x;
      paths.add(
        Path()
          ..moveTo(start, 0)
          ..cubicTo(
            start,
            size.height * .55,
            end,
            size.height * .45,
            end,
            size.height,
          ),
      );
    }
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final path in paths) {
      canvas.drawPath(
        path,
        paint
          ..strokeWidth = 4
          ..color = _connector.withValues(alpha: .08)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      canvas.drawPath(
        path,
        paint
          ..strokeWidth = 1.5
          ..color = _connector
          ..maskFilter = null,
      );
    }
  }

  @override
  bool shouldRepaint(_JunctionPainter old) =>
      left != old.left || right != old.right || merge != old.merge;
}
