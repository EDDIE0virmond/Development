import 'package:flutter/material.dart';
import '../../core/network/app_api.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/widgets/glass_surface.dart';

class ClientMonitoring extends StatefulWidget {
  final AppApi api;
  const ClientMonitoring({super.key, required this.api});
  @override
  State<ClientMonitoring> createState() => _ClientMonitoringState();
}

class _ClientMonitoringState extends State<ClientMonitoring> {
  late Future<List<Map<String, dynamic>>> items = widget.api.monitorings();
  @override
  Widget build(
    BuildContext context,
  ) => FutureBuilder<List<Map<String, dynamic>>>(
    future: items,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done)
        return const Center(child: CircularProgressIndicator());
      if (snapshot.hasError) {
        return Center(
          child: GlassSurface(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(snapshot.error.toString()),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () =>
                      setState(() => items = widget.api.monitorings()),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        );
      }
      final plants = snapshot.data ?? [];
      return ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: plants.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sua energia, em detalhes.',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    plants.isEmpty
                        ? 'Nenhuma usina vinculada. Fale com a equipe Rinnovare.'
                        : 'Abra uma usina para consultar a geração e o consumo. Os dados são atualizados sob demanda.',
                    style: const TextStyle(color: AppTheme.muted),
                  ),
                ],
              ),
            );
          }
          final plant = plants[index - 1];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _PlantEnergy(
              key: ValueKey(plant['id']),
              api: widget.api,
              plant: plant,
            ),
          );
        },
      );
    },
  );
}

class _PlantEnergy extends StatefulWidget {
  final AppApi api;
  final Map<String, dynamic> plant;
  const _PlantEnergy({super.key, required this.api, required this.plant});
  @override
  State<_PlantEnergy> createState() => _PlantEnergyState();
}

class _PlantEnergyState extends State<_PlantEnergy> {
  Future<Map<String, dynamic>>? report;
  bool expanded = false;
  String energy(dynamic value) => value is num
      ? '${value.toStringAsFixed(1).replaceAll('.', ',')} kWh'
      : 'Não disponível';
  @override
  Widget build(BuildContext context) => GlassSurface(
    blur: false,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.solar_power_outlined, color: AppTheme.lime),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.plant['name'] as String,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    (widget.plant['provider'] as String).toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.muted,
                      fontSize: 11,
                      letterSpacing: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          icon: Icon(expanded ? Icons.expand_less : Icons.insights_outlined),
          label: Text(expanded ? 'Recolher' : 'Consultar energia'),
          onPressed: () => setState(() {
            expanded = !expanded;
            if (expanded) {
              report ??= widget.api.monitoringEnergy(
                widget.plant['id'] as String,
              );
            }
          }),
        ),
        if (expanded)
          FutureBuilder<Map<String, dynamic>>(
            future: report,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done)
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                );
              if (snapshot.hasError)
                return Column(
                  children: [
                    Text(snapshot.error.toString()),
                    TextButton(
                      onPressed: () => setState(
                        () => report = widget.api.monitoringEnergy(
                          widget.plant['id'] as String,
                        ),
                      ),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                );
              final data = snapshot.data!;
              final period = data['period'] as Map?;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 24,
                    runSpacing: 20,
                    children: [
                      for (final metric in const {
                        'generationToday': 'Geração · dia',
                        'generationMonth': 'Geração · mês',
                        'consumptionToday': 'Consumo · dia',
                        'consumptionMonth': 'Consumo · mês',
                      }.entries)
                        SizedBox(
                          width: 210,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                metric.value,
                                style: const TextStyle(color: AppTheme.muted),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                energy(data[metric.key]),
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Referência: ${period?['day'] ?? 'Não informada'} · ${period?['timezone'] ?? ''}',
                    style: const TextStyle(color: AppTheme.muted, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Consumo depende da medição disponibilizada pelo fornecedor. Não disponível não significa zero. O mês atual ainda está em andamento.',
                    style: TextStyle(color: AppTheme.muted, fontSize: 12),
                  ),
                  if (data['stale'] == true)
                    const Text(
                      'A última leitura está desatualizada.',
                      style: TextStyle(color: Colors.amber),
                    ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () => setState(
                      () => report = widget.api.monitoringEnergy(
                        widget.plant['id'] as String,
                      ),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Atualizar dia e mês'),
                  ),
                ],
              );
            },
          ),
      ],
    ),
  );
}
