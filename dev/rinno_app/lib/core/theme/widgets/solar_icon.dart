// lib/core/theme/widgets/solar_icon.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

class SolarIcon extends StatelessWidget {
  final double size;
  final Color color;
  final int rows;
  final int columns;

  const SolarIcon({
    super.key,
    this.size = 40,
    this.color = const Color(0xFF2E7D32),
    this.rows = 2,
    this.columns = 3,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SolarIconPainter(
          color: color,
          rows: rows,
          columns: columns,
        ),
        size: Size(size, size),
      ),
    );
  }
}

class _SolarIconPainter extends CustomPainter {
  final Color color;
  final int rows;
  final int columns;

  _SolarIconPainter({
    required this.color,
    required this.rows,
    required this.columns,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Cores e Pincéis
    final Paint fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Paint strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.055
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // ===== 1. SOL (Canto Superior Esquerdo) - AMARELO =====
    final Paint sunPaint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.055
      ..strokeCap = StrokeCap.round;

    final Paint sunFillPaint = Paint()
      ..color = Colors.amber.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final Offset sunCenter = Offset(w * 0.28, h * 0.22);
    final double sunRadius = w * 0.12;

    // Círculo interno do sol (preenchido)
    canvas.drawCircle(sunCenter, sunRadius * 0.5, sunFillPaint);

    // Arco do Sol (amarelo)
    canvas.drawArc(
      Rect.fromCircle(center: sunCenter, radius: sunRadius),
      1.0 * math.pi,
      1.35 * math.pi,
      false,
      sunPaint,
    );

    // Raios do Sol (amarelos)
    final List<double> rayAngles = [
      0.9 * math.pi,
      1.12 * math.pi,
      1.35 * math.pi,
      1.58 * math.pi,
      1.8 * math.pi,
    ];

    for (final double angle in rayAngles) {
      final double rayStartX = sunCenter.dx + (sunRadius * 1.35) * math.cos(angle);
      final double rayStartY = sunCenter.dy + (sunRadius * 1.35) * math.sin(angle);
      final double rayEndX = sunCenter.dx + (sunRadius * 1.65) * math.cos(angle);
      final double rayEndY = sunCenter.dy + (sunRadius * 1.65) * math.sin(angle);

      canvas.drawLine(
        Offset(rayStartX, rayStartY),
        Offset(rayEndX, rayEndY),
        sunPaint..strokeWidth = w * 0.045,
      );
    }

    // ===== 2. SUPORTE DA PLACA (Triângulo Traseiro) =====
    final Path wedgePath = Path()
      ..moveTo(w * 0.91, h * 0.24)
      ..lineTo(w * 0.71, h * 0.64)
      ..lineTo(w * 0.91, h * 0.64)
      ..close();
    canvas.drawPath(wedgePath, fillPaint);

    // ===== 3. PAINEL SOLAR (Perspectiva Paralelogramo) =====
    final Offset topLeft = Offset(w * 0.32, h * 0.24);
    final Offset topRight = Offset(w * 0.91, h * 0.24);
    final Offset bottomRight = Offset(w * 0.71, h * 0.64);
    final Offset bottomLeft = Offset(w * 0.12, h * 0.64);

    // Borda externa do Painel
    final Path panelOutlinePath = Path()
      ..moveTo(topLeft.dx, topLeft.dy)
      ..lineTo(topRight.dx, topRight.dy)
      ..lineTo(bottomRight.dx, bottomRight.dy)
      ..lineTo(bottomLeft.dx, bottomLeft.dy)
      ..close();

    canvas.drawPath(panelOutlinePath, strokePaint..strokeWidth = w * 0.055);

    // Função auxiliar para calcular coordenadas internas
    Offset getSkewedOffset(double u, double t) {
      final double y = topLeft.dy + t * (bottomLeft.dy - topLeft.dy);
      final double xStart = topLeft.dx + t * (bottomLeft.dx - topLeft.dx);
      final double xEnd = topRight.dx + t * (bottomRight.dx - topRight.dx);
      final double x = xStart + u * (xEnd - xStart);
      return Offset(x, y);
    }

    // Geração das células fotovoltaicas
    final List<double> uMins = [];
    final List<double> uMaxs = [];
    final double uGap = 0.05;
    final double uWidth = (0.80 - (uGap * (columns - 1))) / columns;
    for (int i = 0; i < columns; i++) {
      uMins.add(0.10 + i * (uWidth + uGap));
      uMaxs.add(0.10 + i * (uWidth + uGap) + uWidth);
    }

    final List<double> tMins = [];
    final List<double> tMaxs = [];
    final double tGap = 0.06;
    final double tHeight = (0.80 - (tGap * (rows - 1))) / rows;
    for (int i = 0; i < rows; i++) {
      tMins.add(0.10 + i * (tHeight + tGap));
      tMaxs.add(0.10 + i * (tHeight + tGap) + tHeight);
    }

    // Desenhar cada célula individualmente
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < columns; c++) {
        final pTL = getSkewedOffset(uMins[c], tMins[r]);
        final pTR = getSkewedOffset(uMaxs[c], tMins[r]);
        final pBR = getSkewedOffset(uMaxs[c], tMaxs[r]);
        final pBL = getSkewedOffset(uMins[c], tMaxs[r]);

        final Path cellPath = Path()
          ..moveTo(pTL.dx, pTL.dy)
          ..lineTo(pTR.dx, pTR.dy)
          ..lineTo(pBR.dx, pBR.dy)
          ..lineTo(pBL.dx, pBL.dy)
          ..close();

        canvas.drawPath(cellPath, fillPaint);
      }
    }

    // ===== 4. CABO DE ENERGIA =====
    final Path wirePath = Path()
      ..moveTo(w * 0.415, h * 0.64)
      ..lineTo(w * 0.415, h * 0.72)
      ..arcToPoint(
        Offset(w * 0.355, h * 0.78),
        radius: Radius.circular(w * 0.06),
        clockwise: true,
      )
      ..lineTo(w * 0.23, h * 0.78)
      ..arcToPoint(
        Offset(w * 0.23, h * 0.88),
        radius: Radius.circular(w * 0.05),
        clockwise: false,
      )
      ..lineTo(w * 0.65, h * 0.88);

    canvas.drawPath(
      wirePath,
      strokePaint
        ..strokeWidth = w * 0.055
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // ===== 5. PLUGUE DE TOMADA =====
    final Rect plugRect = Rect.fromLTRB(w * 0.65, h * 0.815, w * 0.81, h * 0.945);
    final RRect plugRRect = RRect.fromRectAndRadius(
      plugRect,
      Radius.circular(w * 0.025),
    );
    canvas.drawRRect(plugRRect, fillPaint);

    // Pinos metálicos do plugue
    final Paint prongPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.04
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(w * 0.81, h * 0.85), Offset(w * 0.89, h * 0.85), prongPaint);
    canvas.drawLine(Offset(w * 0.81, h * 0.91), Offset(w * 0.89, h * 0.91), prongPaint);
  }

  @override
  bool shouldRepaint(covariant _SolarIconPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.rows != rows ||
        oldDelegate.columns != columns;
  }
}