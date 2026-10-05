import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/installation.dart';
import '../../core/network/app_api.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/widgets/glass_surface.dart';

class ClientHomePage extends StatefulWidget {
  final AppApi api;
  const ClientHomePage({super.key, required this.api});
  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  late Future<InstallationPage> page = widget.api.installations();
  final List<Installation> previous = [];
  String? selected;

  Future<void> logout() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await widget.api.logout();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, size) => Row(
      children: [
        if (size.maxWidth >= 1100)
          SizedBox(
            width: 250,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BrandMark(),
                  const SizedBox(height: 64),
                  const Text(
                    'SEU PORTAL',
                    style: TextStyle(
                      color: AppTheme.muted,
                      letterSpacing: 2,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    selected: true,
                    selectedColor: AppTheme.lime,
                    leading: const Icon(Icons.solar_power_outlined),
                    title: const Text('Instalações'),
                    onTap: () => setState(() => selected = null),
                  ),
                  const Spacer(),
                  const Text(
                    'Energia que aproxima.',
                    style: TextStyle(color: AppTheme.muted),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        Expanded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    if (size.maxWidth < 1100)
                      const Expanded(child: BrandMark(compact: true))
                    else
                      const Expanded(
                        child: Text(
                          'ACOMPANHE SUA ENERGIA',
                          style: TextStyle(
                            color: AppTheme.muted,
                            fontSize: 11,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    IconButton(
                      tooltip: 'Sair',
                      onPressed: logout,
                      icon: const Icon(Icons.logout),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: selected != null
                    ? _Detail(
                        key: ValueKey(selected),
                        api: widget.api,
                        id: selected!,
                        back: () => setState(() => selected = null),
                      )
                    : FutureBuilder<InstallationPage>(
                        future: page,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState != ConnectionState.done) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasError) {
                            return _Error(
                              error: snapshot.error!,
                              retry: () => setState(
                                () => page = widget.api.installations(
                                  offset: previous.length,
                                ),
                              ),
                            );
                          }
                          final data = snapshot.data!;
                          final items = [...previous, ...data.items];
                          return SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 1100,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const Text(
                                      'BEM-VINDO AO SEU PORTAL',
                                      style: TextStyle(
                                        color: AppTheme.lime,
                                        fontSize: 11,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Olá, ${widget.api.user!.nome.split(' ').first}.',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineLarge,
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Cada etapa da sua instalação, mais perto de você.',
                                      style: TextStyle(
                                        color: AppTheme.muted,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    GlassSurface(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Icons.wb_sunny_outlined,
                                            color: AppTheme.lime,
                                            size: 36,
                                          ),
                                          const SizedBox(width: 20),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Sua energia está em boas mãos.',
                                                  style: Theme.of(
                                                    context,
                                                  ).textTheme.titleLarge,
                                                ),
                                                const SizedBox(height: 8),
                                                const Text(
                                                  'Consulte o andamento e os documentos disponibilizados pela nossa equipe.',
                                                  style: TextStyle(
                                                    color: AppTheme.muted,
                                                    height: 1.6,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 36),
                                    Text(
                                      'Minhas instalações',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineSmall,
                                    ),
                                    const SizedBox(height: 20),
                                    if (items.isEmpty)
                                      const GlassSurface(
                                        child: Text(
                                          'Nenhuma instalação por aqui ainda\nAssim que sua instalação for vinculada, ela aparecerá aqui.',
                                        ),
                                      ),
                                    LayoutBuilder(
                                      builder: (context, c) => Wrap(
                                        spacing: 20,
                                        runSpacing: 20,
                                        children: items
                                            .map(
                                              (item) => SizedBox(
                                                width: c.maxWidth >= 700
                                                    ? (c.maxWidth - 20) / 2
                                                    : c.maxWidth,
                                                child: GlassSurface(
                                                  blur: false,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .stretch,
                                                    children: [
                                                      const Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Icon(
                                                          Icons
                                                              .solar_power_outlined,
                                                          color: AppTheme.lime,
                                                          size: 32,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 24,
                                                      ),
                                                      Text(
                                                        item.codigo,
                                                        style: Theme.of(
                                                          context,
                                                        ).textTheme.titleLarge,
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        item.statusLabel,
                                                        style: const TextStyle(
                                                          color: AppTheme.lime,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 24,
                                                      ),
                                                      Text(
                                                        '${item.potenciaKwp.toStringAsFixed(2)} kWp',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .headlineMedium,
                                                      ),
                                                      const Text(
                                                        'Potência do sistema',
                                                        style: TextStyle(
                                                          color: AppTheme.muted,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 24,
                                                      ),
                                                      OutlinedButton(
                                                        onPressed: () =>
                                                            setState(
                                                              () => selected =
                                                                  item.id,
                                                            ),
                                                        child: const Text(
                                                          'Ver instalação',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                    if (data.hasMore)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 24),
                                        child: OutlinedButton(
                                          onPressed: () => setState(() {
                                            previous.addAll(data.items);
                                            page = widget.api.installations(
                                              offset: previous.length,
                                            );
                                          }),
                                          child: const Text('Carregar mais'),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Error extends StatelessWidget {
  final Object error;
  final VoidCallback retry;
  const _Error({required this.error, required this.retry});
  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 36),
          const SizedBox(height: 16),
          Text(
            error is ApiException
                ? error.toString()
                : 'Não foi possível carregar os dados.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: retry,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    ),
  );
}

class _Detail extends StatefulWidget {
  final AppApi api;
  final String id;
  final VoidCallback back;
  const _Detail({
    super.key,
    required this.api,
    required this.id,
    required this.back,
  });
  @override
  State<_Detail> createState() => _DetailState();
}

class _DetailState extends State<_Detail> {
  late Future<(Installation, List<InstallationStage>, List<ClientDocument>)>
  data = load();
  String? downloading;
  Future<(Installation, List<InstallationStage>, List<ClientDocument>)>
  load() async {
    final values = await Future.wait<Object>([
      widget.api.installation(widget.id),
      widget.api.stages(widget.id),
      widget.api.documents(widget.id),
    ]);
    return (
      values[0] as Installation,
      values[1] as List<InstallationStage>,
      values[2] as List<ClientDocument>,
    );
  }

  Future<void> openDocument(ClientDocument document) async {
    setState(() => downloading = document.id);
    try {
      final uri = await widget.api.download(document.id);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Documento pronto'),
          content: Text(
            'Abrir ${document.nome}? O link expira em 60 segundos.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  if (!await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  )) {
                    throw Exception();
                  }
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                } catch (_) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Não foi possível abrir o documento. Tente novamente.',
                        ),
                      ),
                    );
                  }
                }
              },
              child: const Text('Abrir documento'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is ApiException
                  ? e.message
                  : 'Não foi possível abrir o documento.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => downloading = null);
    }
  }

  String date(DateTime? value) => value == null
      ? 'A confirmar'
      : '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
  @override
  Widget build(
    BuildContext context,
  ) => FutureBuilder<(Installation, List<InstallationStage>, List<ClientDocument>)>(
    future: data,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return _Error(
          error: snapshot.error!,
          retry: () => setState(() => data = load()),
        );
      }
      final (installation, stages, documents) = snapshot.data!;
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: widget.back,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Minhas instalações'),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  installation.codigo,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  installation.statusLabel,
                  style: const TextStyle(color: AppTheme.lime),
                ),
                const SizedBox(height: 28),
                GlassSurface(
                  child: Wrap(
                    spacing: 40,
                    runSpacing: 24,
                    children: [
                      _Metric(
                        '${installation.potenciaKwp.toStringAsFixed(2)} kWp',
                        'Potência instalada',
                      ),
                      _Metric('${installation.quantidadeModulos}', 'Módulos'),
                      _Metric(
                        date(installation.dataPrevisaoEntrega),
                        'Previsão de entrega',
                      ),
                      if (installation.dataConclusao != null)
                        _Metric(date(installation.dataConclusao), 'Conclusão'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Etapas da instalação',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                GlassSurface(
                  blur: false,
                  child: Column(
                    children: [
                      if (stages.isEmpty)
                        const Text(
                          'As etapas serão disponibilizadas pela equipe.',
                        ),
                      for (final stage in stages)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                stage.completed
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: stage.completed
                                    ? AppTheme.lime
                                    : AppTheme.muted,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      stage.nome,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${stage.label}${stage.dataConclusao == null ? '' : ' · ${date(stage.dataConclusao)}'}',
                                      style: const TextStyle(
                                        color: AppTheme.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Seus documentos',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                GlassSurface(
                  blur: false,
                  child: Column(
                    children: [
                      if (documents.isEmpty)
                        const Text('Nenhum documento disponibilizado ainda.'),
                      for (final document in documents)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(
                            Icons.description_outlined,
                            color: AppTheme.lime,
                          ),
                          title: Text(document.nome),
                          subtitle: Text(document.tipo),
                          trailing: IconButton(
                            tooltip: 'Abrir documento',
                            onPressed: downloading != null
                                ? null
                                : () => openDocument(document),
                            icon: downloading == document.id
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.open_in_new),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _Metric extends StatelessWidget {
  final String value, label;
  const _Metric(this.value, this.label);
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(value, style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 6),
      Text(label, style: const TextStyle(color: AppTheme.muted)),
    ],
  );
}

