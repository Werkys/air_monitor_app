import 'dart:math';
import '../models/air_data_point.dart';
import '../models/room.dart';

class AirQualityService {
  static final List<Room> sampleRooms = [
    Room(
      id: 'r_204',
      name: 'Učebna 204 – Fyzika',
      building: 'Budova A',
      floor: 2,
      capacity: 32,
      co2WarnLimit: 1000,
      co2CritLimit: 1500,
      currentReading: AirDataPoint(
        timestamp: DateTime.now(),
        co2: 1240,
        temperature: 22.8,
        humidity: 52.0,
      ),
    ),
    Room(
      id: 'r_101',
      name: 'Učebna 101 – Český jazyk',
      building: 'Budova A',
      floor: 1,
      capacity: 30,
      co2WarnLimit: 1000,
      co2CritLimit: 1500,
      currentReading: AirDataPoint(
        timestamp: DateTime.now(),
        co2: 720,
        temperature: 21.2,
        humidity: 45.0,
      ),
    ),
    Room(
      id: 'r_it',
      name: 'Laboratoř IT – 3.B',
      building: 'Budova B',
      floor: 1,
      capacity: 24,
      co2WarnLimit: 1000,
      co2CritLimit: 1500,
      currentReading: AirDataPoint(
        timestamp: DateTime.now(),
        co2: 1850,
        temperature: 24.1,
        humidity: 58.0,
      ),
    ),
    Room(
      id: 'r_sbor',
      name: 'Sborovna A',
      building: 'Budova A',
      floor: 2,
      capacity: 15,
      co2WarnLimit: 1000,
      co2CritLimit: 1500,
      currentReading: AirDataPoint(
        timestamp: DateTime.now(),
        co2: 610,
        temperature: 20.8,
        humidity: 43.0,
      ),
    ),
    Room(
      id: 'r_demo',
      name: 'Demo Sonda 2',
      building: 'Budova A',
      floor: 2,
      capacity: 28,
      co2WarnLimit: 1000,
      co2CritLimit: 1500,
      currentReading: AirDataPoint(
        timestamp: DateTime.now(),
        co2: 1100,
        temperature: 22.0,
        humidity: 49.0,
      ),
    ),
  ];

  static List<AirDataPoint> getWeekData(String roomId) {
    final now = DateTime.now();
    final List<AirDataPoint> points = [];
    final rand = Random(roomId.hashCode + now.day);

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
      final baseCo2 = isWeekend ? 450 + rand.nextInt(80) : 950 + rand.nextInt(450);
      final temp = 21.0 + (rand.nextDouble() * 2.5 - 1.0);
      final hum = 45.0 + (rand.nextDouble() * 10.0 - 5.0);

      const dayNames = ['Po', 'Út', 'St', 'Čt', 'Pá', 'So', 'Ne'];
      final dayLabel = '${dayNames[date.weekday - 1]} ${date.day}.${date.month}.';

      points.add(AirDataPoint(
        timestamp: date,
        co2: baseCo2,
        temperature: double.parse(temp.toStringAsFixed(1)),
        humidity: double.parse(hum.toStringAsFixed(1)),
        label: dayLabel,
      ));
    }
    return points;
  }

  static List<AirDataPoint> getMonthData(String roomId, int year, int month) {
    final List<AirDataPoint> points = [];
    final rand = Random(roomId.hashCode + year * 100 + month);
    final daysInMonth = DateTime(year, month + 1, 0).day;

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;

      int seasonalOffset = (month >= 11 || month <= 2) ? 150 : 0;
      int co2 = isWeekend
          ? 430 + rand.nextInt(90)
          : 900 + seasonalOffset + rand.nextInt(600);

      double temp = 20.5 + (rand.nextDouble() * 3.0);
      double hum = 42.0 + (rand.nextDouble() * 12.0);

      points.add(AirDataPoint(
        timestamp: date,
        co2: co2,
        temperature: double.parse(temp.toStringAsFixed(1)),
        humidity: double.parse(hum.toStringAsFixed(1)),
        label: '$day.',
      ));
    }
    return points;
  }

  static List<AirDataPoint> getYearData(String roomId, int year) {
    final List<AirDataPoint> points = [];
    final rand = Random(roomId.hashCode + year);

    const monthNames = [
      'Led', 'Úno', 'Bře', 'Dub', 'Kvě', 'Čvn',
      'Čvc', 'Srp', 'Zář', 'Říj', 'Lis', 'Pro'
    ];

    for (int month = 1; month <= 12; month++) {
      final date = DateTime(year, month, 15);
      final isHolidays = month == 7 || month == 8;
      int co2;
      if (isHolidays) {
        co2 = 460 + rand.nextInt(60);
      } else if (month <= 2 || month >= 11) {
        co2 = 1250 + rand.nextInt(350);
      } else {
        co2 = 980 + rand.nextInt(300);
      }

      double temp = 19.5 + (month >= 5 && month <= 9 ? 4.5 : 1.5) + rand.nextDouble();
      double hum = 40.0 + rand.nextDouble() * 15.0;

      points.add(AirDataPoint(
        timestamp: date,
        co2: co2,
        temperature: double.parse(temp.toStringAsFixed(1)),
        humidity: double.parse(hum.toStringAsFixed(1)),
        label: monthNames[month - 1],
      ));
    }
    return points;
  }
}
