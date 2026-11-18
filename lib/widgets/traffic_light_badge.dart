import 'package:flutter/material.dart';

class TrafficLightBadge extends StatelessWidget {
  final int co2;
  final int warnLimit;
  final int critLimit;

  const TrafficLightBadge({
    super.key,
    required this.co2,
    this.warnLimit = 1000,
    this.critLimit = 1500,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;

    if (co2 < warnLimit) {
      bg = const Color(0xFFE8F5E9);
      fg = const Color(0xFF1B5E20);
      label = 'OPTIMÁLNÍ STAV';
    } else if (co2 < critLimit) {
      bg = const Color(0xFFFFF8E1);
      fg = const Color(0xFFB78103);
      label = 'ZVÝŠENÁ HLADINA';
    } else {
      bg = const Color(0xFFFFEBEE);
      fg = const Color(0xFFB71C1C);
      label = 'KRITICKÁ HLADINA';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: fg, width: 1.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
