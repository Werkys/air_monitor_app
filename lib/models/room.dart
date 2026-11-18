import 'air_data_point.dart';

class Room {
  final String id;
  final String name;
  final String building;
  final int floor;
  final int capacity;
  final int co2WarnLimit;
  final int co2CritLimit;
  final AirDataPoint currentReading;

  const Room({
    required this.id,
    required this.name,
    required this.building,
    required this.floor,
    required this.capacity,
    this.co2WarnLimit = 1000,
    this.co2CritLimit = 1500,
    required this.currentReading,
  });

  bool get isOptimal => currentReading.co2 < co2WarnLimit;
  bool get isWarning => currentReading.co2 >= co2WarnLimit && currentReading.co2 < co2CritLimit;
  bool get isCritical => currentReading.co2 >= co2CritLimit;
}
