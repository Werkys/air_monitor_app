import 'package:flutter/material.dart';
import '../models/air_data_point.dart';

class PeriodSelector extends StatelessWidget {
  final PeriodType currentPeriod;
  final int selectedMonth;
  final int selectedYear;
  final ValueChanged<PeriodType> onPeriodChanged;
  final ValueChanged<int> onMonthChanged;
  final ValueChanged<int> onYearChanged;

  const PeriodSelector({
    super.key,
    required this.currentPeriod,
    required this.selectedMonth,
    required this.selectedYear,
    required this.onPeriodChanged,
    required this.onMonthChanged,
    required this.onYearChanged,
  });

  static const List<String> monthNames = [
    'Leden', 'Únor', 'Březen', 'Duben', 'Květen', 'Červen',
    'Červenec', 'Srpen', 'Září', 'Říjen', 'Listopad', 'Prosinec'
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFD9D9D9), width: 1),
          ),
          child: Row(
            children: [
              _buildTab('TÝDEN', PeriodType.week),
              _buildTab('MĚSÍC', PeriodType.month),
              _buildTab('ROK', PeriodType.year),
            ],
          ),
        ),
        if (currentPeriod == PeriodType.month) ...[
          const SizedBox(height: 8),
          _buildMonthPickerBar(context),
        ] else if (currentPeriod == PeriodType.year) ...[
          const SizedBox(height: 8),
          _buildYearPickerBar(context),
        ],
      ],
    );
  }

  Widget _buildTab(String label, PeriodType type) {
    final isSelected = currentPeriod == type;
    return Expanded(
      child: InkWell(
        onTap: () => onPeriodChanged(type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0087CD) : Colors.transparent,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : const Color(0xFF4B5563),
              fontSize: 12,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthPickerBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        border: Border.all(color: const Color(0xFFD9D9D9)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'ZVOLENÉ OBDOBÍ:',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4B5563),
            ),
          ),
          Row(
            children: [
              DropdownButton<int>(
                value: selectedMonth,
                underline: const SizedBox(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                  fontSize: 13,
                ),
                items: List.generate(12, (index) {
                  final m = index + 1;
                  return DropdownMenuItem<int>(
                    value: m,
                    child: Text(monthNames[index]),
                  );
                }),
                onChanged: (newMonth) {
                  if (newMonth != null) onMonthChanged(newMonth);
                },
              ),
              const SizedBox(width: 12),
              DropdownButton<int>(
                value: selectedYear,
                underline: const SizedBox(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                  fontSize: 13,
                ),
                items: [2025, 2026, 2027].map((y) {
                  return DropdownMenuItem<int>(
                    value: y,
                    child: Text('Rok $y'),
                  );
                }).toList(),
                onChanged: (newYear) {
                  if (newYear != null) onYearChanged(newYear);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildYearPickerBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        border: Border.all(color: const Color(0xFFD9D9D9)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'ZVOLENÝ ROK:',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4B5563),
            ),
          ),
          DropdownButton<int>(
            value: selectedYear,
            underline: const SizedBox(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
              fontSize: 13,
            ),
            items: [2025, 2026, 2027].map((y) {
              return DropdownMenuItem<int>(
                value: y,
                child: Text('Rok $y'),
              );
            }).toList(),
            onChanged: (newYear) {
              if (newYear != null) onYearChanged(newYear);
            },
          ),
        ],
      ),
    );
  }
}
