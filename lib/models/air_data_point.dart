class AirDataPoint {
  final DateTime timestamp;
  final int co2; // v ppm
  final double temperature; // ve °C
  final double humidity; // v %
  final String? label;

  const AirDataPoint({
    required this.timestamp,
    required this.co2,
    required this.temperature,
    required this.humidity,
    this.label,
  });

  bool get isWarning => co2 >= 1000 && co2 < 1500;
  bool get isCritical => co2 >= 1500;
  bool get isOptimal => co2 < 1000;
}

enum PeriodType {
  week,
  month,
  year,
}
