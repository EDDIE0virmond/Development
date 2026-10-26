import 'card_detail_page.dart';
import 'package:flutter/material.dart';
import 'monitoring_history.dart';
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
      if (snapshot.connectionState != ConnectionState.done) {
        return const Center(child: CircularProgressIndicator());
      }
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
      if (plants.isEmpty) return const SizedBox.shrink();
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 36),
        itemCount: plants.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monitoramento',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    plants.isEmpty
                        ? 'Nenhuma usina vinculada. Fale com a equipe Rinnovare.'
                        : 'Veja a geração do dia e do mês. Toque na usina para abrir os gráficos e detalhes.',
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

String _energy(dynamic value) => value is num && value.isFinite && value >= 0
    ? '${value.toStringAsFixed(1).replaceAll('.', ',')} kWh'
    : 'Não disponível';

class _PlantEnergyState extends State<_PlantEnergy> {
  late Future<Map<String, dynamic>> report = load();
  Future<Map<String, dynamic>> load() =>
      widget.api.monitoringEnergy(widget.plant['id'] as String);

  void openDetails() {
    openCardPage(
      context,
      title: widget.plant['name'] as String,
      builder: (context) => StatefulBuilder(
        builder: (context, updatePage) => SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            MediaQuery.sizeOf(context).width < 600 ? 16 : 24,
            8,
            MediaQuery.sizeOf(context).width < 600 ? 16 : 24,
            32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GlassSurface(
                padding: EdgeInsets.all(
                  MediaQuery.sizeOf(context).width < 600 ? 16 : 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Resumo atual',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(
                      height: MediaQuery.sizeOf(context).width < 600 ? 8 : 16,
                    ),
                    _reportView(details: true),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.sizeOf(context).width < 600 ? 10 : 20,
              ),
              GlassSurface(
                padding: EdgeInsets.all(
                  MediaQuery.sizeOf(context).width < 600 ? 16 : 24,
                ),
                child: MonitoringHistory(
                  api: widget.api,
                  id: widget.plant['id'] as String,
                ),
              ),
              if (MediaQuery.sizeOf(context).width < 600)
                _reportView(details: true, metadataOnly: true),
              const SizedBox(height: 24),
              TextButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Atualizar leitura'),
                onPressed: () {
                  setState(() => report = load());
                  updatePage(() {});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reportView({
    bool details = false,
    bool metadataOnly = false,
  }) => FutureBuilder<Map<String, dynamic>>(
    future: report,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: CircularProgressIndicator(
              semanticsLabel: 'Carregando geração',
            ),
          ),
        );
      }
      if (snapshot.hasError) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Não foi possível carregar a leitura. Abra os detalhes e tente atualizar.',
          ),
        );
      }
      final data = snapshot.data!;
      final period = data['period'] as Map?;
      final compact = details && MediaQuery.sizeOf(context).width < 600;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: compact ? 0 : 20),
          if (!metadataOnly)
            Row(
              children: [
                for (final metric in const {
                  'generationToday': 'Geração · dia',
                  'generationMonth': 'Geração · mês',
                }.entries)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            compact
                                ? (metric.key == 'generationToday'
                                      ? 'Hoje'
                                      : 'Este mês')
                                : metric.value,
                            style: const TextStyle(color: AppTheme.muted),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _energy(data[metric.key]),
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(color: AppTheme.lime),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          if (data['stale'] == true)
            const Text(
              'Última leitura desatualizada',
              style: TextStyle(color: Colors.amber),
            ),
          if (details && (!compact || metadataOnly)) ...[
            SizedBox(height: compact ? 4 : 24),
            if (compact)
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: 8),
                dense: true,
                minTileHeight: 36,
                title: const Text(
                  'Detalhes da leitura',
                  style: TextStyle(fontSize: 12),
                ),
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Fornecedor: ${(widget.plant['provider'] as String).toUpperCase()}',
                      ),
                      Text(
                        'Dia de referência: ${period?['day'] ?? 'Não informado'}',
                      ),
                      Text(
                        'Fuso horário: ${period?['timezone'] ?? 'Não informado'}',
                      ),
                      Text(
                        'Última consulta: ${data['fetchedAt'] ?? 'Não informada'}',
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Geração acumulada na última leitura disponível. O mês atual está em andamento.',
                        style: TextStyle(color: AppTheme.muted, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              )
            else ...[
              Text(
                'Fornecedor: ${(widget.plant['provider'] as String).toUpperCase()}',
              ),
              Text('Dia de referência: ${period?['day'] ?? 'Não informado'}'),
              Text('Fuso horário: ${period?['timezone'] ?? 'Não informado'}'),
              Text('Última consulta: ${data['fetchedAt'] ?? 'Não informada'}'),
              const SizedBox(height: 12),
              const Text(
                'Geração acumulada na última leitura disponível. O mês atual está em andamento.',
                style: TextStyle(color: AppTheme.muted, fontSize: 12),
              ),
            ],
          ],
        ],
      );
    },
  );

  @override
  Widget build(BuildContext context) => GlassSurface(
    blur: false,
    padding: EdgeInsets.zero,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: openDetails,
        borderRadius: BorderRadius.circular(26),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.solar_power_outlined, color: AppTheme.lime),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.plant['name'] as String,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              _reportView(),
              const SizedBox(height: 16),
              const Text(
                'Ver gráficos e detalhes',
                style: TextStyle(color: AppTheme.muted),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
