import 'package:flutter/material.dart';
import '../../core/models/installation.dart';
import '../../core/theme/app_theme.dart';

/// The API supplies workflow order; filtering must preserve that order.
class CompletedStagesTimeline extends StatelessWidget {
  final List<InstallationStage> stages;
  const CompletedStagesTimeline({super.key, required this.stages});

  @override
  Widget build(BuildContext context) {
    final completed = stages.where((stage) => stage.completed).toList();
    if (completed.isEmpty) {
      return const Text('As etapas concluídas aparecerão aqui.');
    }
    return Column(
      children: [
        for (var index = 0; index < completed.length; index++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 52,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      if (index < completed.length - 1)
                        Positioned(
                          top: 26,
                          bottom: 0,
                          child: Container(width: 3, color: AppTheme.lime),
                        ),
                      Container(
                        width: 52,
                        height: 52,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.lime.withValues(alpha: .20),
                        ),
                        child: const DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.lime,
                          ),
                          child: ExcludeSemantics(
                            child: Icon(
                              Icons.check_rounded,
                              color: AppTheme.navy,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 5,
                      bottom: index < completed.length - 1 ? 28 : 5,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          completed[index].nome,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          completed[index].dataConclusao == null
                              ? 'Concluída'
                              : 'Concluída · ${MaterialLocalizations.of(context).formatCompactDate(completed[index].dataConclusao!)}',
                          style: const TextStyle(color: AppTheme.muted),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
