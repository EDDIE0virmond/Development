import 'dart:math' as math;
import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
final double size;

const LogoWidget({Key? key, this.size = 200.0}) : super(key: key);

@override
Widget build(BuildContext context) {
return Center(
child: CustomPaint(
size: Size(size, size),
painter: LogoPainter(),
),
);
}
}

class LogoPainter extends CustomPainter {
@override
void paint(Canvas canvas, Size size) {
final double radius = size.width / 2;
final Offset center = Offset(radius, radius);

// Altura da linha do horizonte (espessura do espaço branco)
final double horizonThickness = size.height * 0.05;

// ---- 1. METADE INFERIOR (Preta) ----
final Paint blackPaint = Paint()
..color = Colors.black
..style = PaintingStyle.fill;

// Criando o arco inferior ligeiramente abaixo do centro para dar o espaçamento
final Rect bottomRect = Rect.fromCircle(center: center, radius: radius);
canvas.drawArc(
bottomRect,
0, // Começa na direita (0 radianos)
math.pi, // Desenha um semicírculo (180 graus)
true,
blackPaint,
);

// ---- 2. METADE SUPERIOR (Verde com Gradiente) ----
final Paint greenPaint = Paint()
..style = PaintingStyle.fill
..shader = LinearGradient(
begin: Alignment.topCenter,
end: Alignment.bottomCenter,
colors: [
Color(0xFF55DD11), // Verde claro no topo
Color(0xFF226611), // Verde escuro na base
],
).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

// Ajusta o início do arco superior para cima para respeitar a linha do horizonte
final Path topHalfPath = Path()
..addArc(
Rect.fromCircle(center: center, radius: radius),
math.pi, // Começa na esquerda
math.pi, // Desenha o semicírculo superior
);

canvas.drawPath(topHalfPath, greenPaint);

// ---- 3. O SOL E OS RAIOS (Brancos) ----
final Paint whitePaint = Paint()
..color = Colors.white
..style = PaintingStyle.fill;

// Centro do sol posicionado na linha do horizonte superior
final double sunRadius = radius * 0.22;
final Offset sunCenter = Offset(radius, radius - (horizonThickness / 2));

// Desenha o semicírculo do sol
canvas.drawArc(
Rect.fromCircle(center: sunCenter, radius: sunRadius),
math.pi,
math.pi,
true,
whitePaint,
);

// Desenho dos 9 raios pontiagudos
final int numRays = 9;
final double startAngle = 195 * math.pi / 180; // ~195° para o primeiro raio à esquerda
final double endAngle = 345 * math.pi / 180; // ~345° para o último raio à direita
final double angleStep = (endAngle - startAngle) / (numRays - 1);

final double rayLength = radius * 0.82; // Comprimento até a ponta do raio
final double baseWidthAngle = 0.04; // Largura da base do raio em radianos

for (int i = 0; i < numRays; i++) {
double currentAngle = startAngle + (i * angleStep);

// Ponta do triângulo (raio)
double tipX = sunCenter.dx + rayLength * math.cos(currentAngle);
double tipY = sunCenter.dy + rayLength * math.sin(currentAngle);

// Base esquerda do triângulo
double baseLeftX = sunCenter.dx + sunRadius * math.cos(currentAngle - baseWidthAngle);
double baseLeftY = sunCenter.dy + sunRadius * math.sin(currentAngle - baseWidthAngle);

// Base direita do triângulo
double baseRightX = sunCenter.dx + sunRadius * math.cos(currentAngle + baseWidthAngle);
double baseRightY = sunCenter.dy + sunRadius * math.sin(currentAngle + baseWidthAngle);

Path rayPath = Path()
..moveTo(baseLeftX, baseLeftY)
..lineTo(tipX, tipY)
..lineTo(baseRightX, baseRightY)
..close();

canvas.drawPath(rayPath, whitePaint);
}
}

@override
bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
