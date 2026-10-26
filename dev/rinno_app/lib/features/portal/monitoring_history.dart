import 'package:flutter/material.dart';
import '../../core/network/app_api.dart';
import '../../core/theme/app_theme.dart';

class MonitoringHistory extends StatefulWidget {
  final AppApi api;
  final String id;
  const MonitoringHistory({super.key, required this.api, required this.id});
  @override
  State<MonitoringHistory> createState() => _MonitoringHistoryState();
}

class _MonitoringHistoryState extends State<MonitoringHistory> {
  final today = DateUtils.dateOnly(DateTime.now());
  late DateTime day = today;
  late DateTime month = DateTime(today.year, today.month);
  bool monthly = false;
  String? serial;
  String? metric;
  final cache = <String, Future<Map<String, dynamic>>>{};
  String iso(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  DateTime get queryDate {
    if (!monthly) return day;
    final end = DateTime(month.year, month.month + 1, 0);
    return end.isAfter(today) ? today : end;
  }

  Future<Map<String, dynamic>> load() {
    final date = iso(queryDate);
    if (!cache.containsKey('$date/$serial') && cache.length >= 12) {
      cache.remove(cache.keys.first);
    }
    return cache.putIfAbsent(
      '$date/$serial',
      () => widget.api.monitoringHistory(widget.id, date, serial: serial),
    );
  }

  Future<void> pickDay() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: day,
      firstDate: today.subtract(const Duration(days: 365)),
      lastDate: today,
    );
    if (picked != null && mounted) {
      setState(() {
        day = picked;
        metric = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SizedBox(height: MediaQuery.sizeOf(context).width < 600 ? 0 : 16),
      const Text(
        'Histórico de geração',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      SizedBox(height: MediaQuery.sizeOf(context).width < 600 ? 6 : 12),
      SegmentedButton<bool>(
        segments: const [
          ButtonSegment(value: false, label: Text('Dia')),
          ButtonSegment(value: true, label: Text('Mês')),
        ],
        selected: {monthly},
        onSelectionChanged: (v) => setState(() {
          monthly = v.first;
          metric = null;
        }),
      ),
      SizedBox(height: MediaQuery.sizeOf(context).width < 600 ? 6 : 12),
      if (!monthly)
        OutlinedButton.icon(
          onPressed: pickDay,
          icon: const Icon(Icons.calendar_today),
          label: Text(
            '${day.day.toString().padLeft(2, '0')}/${day.month.toString().padLeft(2, '0')}/${day.year}',
          ),
        )
      else
        DropdownButtonFormField<DateTime>(
          initialValue: month,
          decoration: const InputDecoration(labelText: 'Mês de referência'),
          items: List.generate(12, (i) {
            final d = DateTime(today.year, today.month - i);
            return DropdownMenuItem(
              value: d,
              child: Text('${d.month.toString().padLeft(2, '0')}/${d.year}'),
            );
          }),
          onChanged: (v) {
            if (v != null) {
              setState(() {
                month = v;
                metric = null;
              });
            }
          },
        ),
      SizedBox(height: MediaQuery.sizeOf(context).width < 600 ? 4 : 16),
      FutureBuilder<Map<String, dynamic>>(
        future: load(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return Column(
              children: [
                const Text('Não foi possível consultar este período.'),
                TextButton(
                  onPressed: () => setState(() => cache.clear()),
                  child: const Text('Tentar novamente'),
                ),
              ],
            );
          }
          final data = snapshot.data!;
          final series = (data['series'] as List? ?? [])
              .whereType<Map>()
              .where((s) => s['period'] == (monthly ? 'month' : 'day'))
              .toList();
          final matches = series.where((s) => s['key'] == metric);
          final selected = matches.isNotEmpty
              ? matches.first
              : (series.isEmpty ? null : series.first);
          final devices = (data['devices'] as List? ?? [])
              .whereType<Map>()
              .where((d) => d['serial'] != null)
              .toList();
          final points = (selected?['points'] as List? ?? [])
              .whereType<Map>()
              .toList();
          final unit = selected?['unit'] as String? ?? '';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (data['scope'] == 'device' && devices.isNotEmpty) ...[
                DropdownButtonFormField<String>(
                  key: ValueKey(data['selectedSerial']),
                  initialValue:
                      devices.any((d) => d['serial'] == data['selectedSerial'])
                      ? data['selectedSerial'] as String?
                      : null,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Equipamento monitorado',
                  ),
                  items: devices
                      .map(
                        (d) => DropdownMenuItem(
                          value: d['serial'] as String,
                          child: Text(
                            '${d['serial']} ${d['model'] ?? ''}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() {
                    serial = v;
                    metric = null;
                  }),
                ),
                SizedBox(
                  height: MediaQuery.sizeOf(context).width < 600 ? 6 : 12,
                ),
              ],
              if (series.length > 1)
                DropdownButtonFormField<String>(
                  key: ValueKey('${monthly}_${selected?['key']}'),
                  initialValue: selected?['key'] as String?,
                  isExpanded: true,
                  items: series
                      .map(
                        (s) => DropdownMenuItem(
                          value: s['key'] as String,
                          child: Text(
                            '${s['label']} ${s['unit'] ?? ''}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => metric = v),
                ),
              if (selected != null)
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.sizeOf(context).width < 600 ? 4 : 12,
                  ),
                  child: Text(
                    '${selected['label']}${unit.isEmpty ? ' • unidade não informada' : ' ($unit)'}',
                  ),
                ),
              if (points.any((p) => p['value'] is num)) ...[
                SizedBox(
                  height: MediaQuery.sizeOf(context).width < 600
                      ? (MediaQuery.sizeOf(context).height - 480).clamp(
                          100.0,
                          190.0,
                        )
                      : 190,
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: _HistoryPainter(points, monthly),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  monthly
                      ? 'Leituras por dia do mês'
                      : 'Leituras por horário do dia',
                  style: const TextStyle(color: Color(0xFFD6E5F0)),
                ),
                ExpansionTile(
                  title: const Text('Ver leituras e horários'),
                  children: [
                    SizedBox(
                      height: 240,
                      child: ListView.builder(
                        itemCount: points.length,
                        itemBuilder: (context, index) {
                          final p = points[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                Expanded(child: Text('${p['time']}')),
                                Text(
                                  p['value'] is num
                                      ? '${(p['value'] as num).toStringAsFixed(2)} $unit'
                                      : 'Não disponível',
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ] else
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'O fornecedor não disponibilizou leituras para este período.',
                  ),
                ),
              if (selected?['timezone'] != null || data['timezone'] != null)
                Text(
                  'Fuso: ${selected?['timezone'] ?? data['timezone']}',
                  style: const TextStyle(color: Color(0xFFD6E5F0)),
                ),
              for (final note in (data['notes'] as List? ?? []))
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '$note',
                    style: const TextStyle(color: Color(0xFFD6E5F0)),
                  ),
                ),
            ],
          );
        },
      ),
    ],
  );
}

class _HistoryPainter extends CustomPainter {
  final List<Map> points;
  final bool bars;
  _HistoryPainter(this.points, this.bars);
  @override
  void paint(Canvas canvas, Size size) {
    final values = points
        .map((p) => p['value'])
        .whereType<num>()
        .where((v) => v.isFinite)
        .toList();
    if (values.isEmpty) return;
    final max = values.fold<double>(0, (a, b) => b > a ? b.toDouble() : a);
    final ceiling = max > 0 ? max : 1.0;
    final plot = Rect.fromLTRB(52, 12, size.width - 8, size.height - 24);
    final ink = Paint()
      ..color = AppTheme.lime
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    void label(String s, Offset pos) {
      final text = TextPainter(
        text: TextSpan(
          text: s,
          style: const TextStyle(color: Color(0xFFD6E5F0), fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(canvas, pos);
    }

    for (var i = 0; i <= 4; i++) {
      final y = plot.bottom - plot.height * i / 4;
      canvas.drawLine(
        Offset(plot.left, y),
        Offset(plot.right, y),
        Paint()..color = Colors.white12,
      );
      label((ceiling * i / 4).toStringAsFixed(1), Offset(0, y - 6));
    }
    final times = points
        .map((p) => DateTime.tryParse('${p['time']}')?.millisecondsSinceEpoch)
        .toList();
    final start = times.first;
    final end = times.last;
    final path = Path();
    var connected = false;
    for (var i = 0; i < points.length; i++) {
      final v = points[i]['value'];
      if (v is! num || !v.isFinite) {
        connected = false;
        continue;
      }
      final fraction =
          start != null && end != null && end > start && times[i] != null
          ? (times[i]! - start) / (end - start)
          : (points.length == 1 ? .5 : i / (points.length - 1));
      final x = plot.left + plot.width * fraction;
      final y = plot.bottom - plot.height * (v / ceiling).clamp(0, 1);
      if (bars) {
        canvas.drawLine(
          Offset(x, plot.bottom),
          Offset(x, y),
          Paint()
            ..color = AppTheme.lime
            ..strokeWidth = (plot.width / points.length * .55).clamp(2, 12),
        );
      } else {
        if (connected) {
          path.lineTo(x, y);
        } else {
          path.moveTo(x, y);
        }
        connected = true;
        canvas.drawCircle(Offset(x, y), 2, Paint()..color = AppTheme.lime);
      }
    }
    if (!bars) canvas.drawPath(path, ink);
    String timeLabel(Map p) {
      final t = DateTime.tryParse('${p['time']}');
      return t == null
          ? '${p['time']}'
          : bars
          ? '${t.day}/${t.month}'
          : '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    }

    label(timeLabel(points.first), Offset(plot.left, plot.bottom + 6));
    label(timeLabel(points.last), Offset(plot.right - 34, plot.bottom + 6));
  }

  @override
  bool shouldRepaint(_HistoryPainter old) =>
      old.points != points || old.bars != bars;
}
