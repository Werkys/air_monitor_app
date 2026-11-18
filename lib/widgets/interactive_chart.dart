import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../models/air_data_point.dart';

class AirQualityChart extends StatelessWidget {
  final List<AirDataPoint> dataPoints;
  final int warnLimit;
  final int critLimit;

  const AirQualityChart({
    super.key,
    required this.dataPoints,
    this.warnLimit = 1000,
    this.critLimit = 1500,
  });

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty) {
      return Container(
        height: 240,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFD9D9D9)),
        ),
        child: const Center(
          child: Text(
            'Žádná data pro vybrané období',
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD9D9D9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            children: [
              const Text(
                'Koncentrace CO2 za období',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: Color(0xFF374151),
                ),
              ),
              Wrap(
                spacing: 14,
                runSpacing: 4,
                children: [
                  _buildLegendItem(const Color(0xFF0087CD), 'Naměřené CO2'),
                  _buildLegendItem(const Color(0xFFD97706), 'Limit 1000 ppm'),
                  _buildLegendItem(const Color(0xFFDC2626), 'Limit 1500 ppm'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            width: double.infinity,
            child: CustomPaint(
              painter: _ChartPainter(
                data: dataPoints,
                warnLimit: warnLimit,
                critLimit: critLimit,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 3,
          color: color,
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF4B5563),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<AirDataPoint> data;
  final int warnLimit;
  final int critLimit;

  _ChartPainter({
    required this.data,
    required this.warnLimit,
    required this.critLimit,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const leftPadding = 48.0;
    const bottomPadding = 24.0;
    const topPadding = 12.0;
    const rightPadding = 12.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    if (chartWidth <= 0 || chartHeight <= 0 || data.isEmpty) return;

    final co2Values = data.map((e) => e.co2).toList();
    final rawMin = co2Values.reduce(min);
    final rawMax = co2Values.reduce(max);

    // Zaokrouhlení mezí osy Y na stovky
    final minY = max(350, ((rawMin - 50) ~/ 100) * 100);
    final maxY = max(critLimit + 200, (((max(rawMax, critLimit) + 150) ~/ 100) * 100));

    double getY(num val) {
      final ratio = (val - minY) / (maxY - minY);
      return topPadding + chartHeight * (1.0 - ratio.clamp(0.0, 1.0));
    }

    double getX(int index) {
      if (data.length == 1) return leftPadding + chartWidth / 2;
      return leftPadding + (index / (data.length - 1)) * chartWidth;
    }

    // Mřížka a popisky osy Y
    final gridPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1.0;

    const ySteps = 4;
    for (int i = 0; i <= ySteps; i++) {
      final val = minY + ((maxY - minY) * i / ySteps).round();
      final y = getY(val);

      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(leftPadding + chartWidth, y),
        gridPaint,
      );

      final tp = TextPainter(
        text: TextSpan(
          text: '$val',
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF6B7280),
            fontFamily: 'monospace',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftPadding - tp.width - 6, y - tp.height / 2));
    }

    // Limit 1000 ppm
    if (warnLimit >= minY && warnLimit <= maxY) {
      final warnY = getY(warnLimit);
      _drawDashedLine(
        canvas,
        Offset(leftPadding, warnY),
        Offset(leftPadding + chartWidth, warnY),
        const Color(0xFFD97706),
      );
    }

    // Limit 1500 ppm
    if (critLimit >= minY && critLimit <= maxY) {
      final critY = getY(critLimit);
      _drawDashedLine(
        canvas,
        Offset(leftPadding, critY),
        Offset(leftPadding + chartWidth, critY),
        const Color(0xFFDC2626),
      );
    }

    // Křivka CO2 s výplní
    final linePath = Path();
    final fillPath = Path();

    linePath.moveTo(getX(0), getY(data[0].co2));
    fillPath.moveTo(getX(0), topPadding + chartHeight);
    fillPath.lineTo(getX(0), getY(data[0].co2));

    for (int i = 1; i < data.length; i++) {
      final prevX = getX(i - 1);
      final prevY = getY(data[i - 1].co2);
      final currX = getX(i);
      final currY = getY(data[i].co2);

      final midX = (prevX + currX) / 2;
      linePath.cubicTo(midX, prevY, midX, currY, currX, currY);
      fillPath.cubicTo(midX, prevY, midX, currY, currX, currY);
    }

    fillPath.lineTo(getX(data.length - 1), topPadding + chartHeight);
    fillPath.close();

    final fillPaint = Paint()
      ..color = const Color(0xFFE8F4FB)
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    final strokePaint = Paint()
      ..color = const Color(0xFF0087CD)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(linePath, strokePaint);

    // Popisky osy X
    final step = max(1, (data.length / 7).floor());
    for (int i = 0; i < data.length; i += step) {
      final x = getX(i);
      final timeStr = _formatTimestamp(data[i].timestamp);
      final tp = TextPainter(
        text: TextSpan(
          text: timeStr,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF6B7280),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, Offset(x - tp.width / 2, topPadding + chartHeight + 6));
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const dashWidth = 5.0;
    const dashSpace = 4.0;
    double startX = p1.dx;

    while (startX < p2.dx) {
      final endX = min(startX + dashWidth, p2.dx);
      canvas.drawLine(Offset(startX, p1.dy), Offset(endX, p1.dy), paint);
      startX += dashWidth + dashSpace;
    }
  }

  String _formatTimestamp(DateTime dt) {
    if (data.length <= 14) {
      return DateFormat('d. M.').format(dt);
    }
    return DateFormat('d.M. H:mm').format(dt);
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.warnLimit != warnLimit ||
        oldDelegate.critLimit != critLimit;
  }
}
