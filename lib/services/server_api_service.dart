import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ServerReading {
  final int co2;
  final double temperature;
  final double humidity;
  final String updatedAt;
  final DateTime timestamp;
  final bool isSuccess;
  final String? errorMessage;

  const ServerReading({
    required this.co2,
    required this.temperature,
    required this.humidity,
    required this.updatedAt,
    required this.timestamp,
    this.isSuccess = true,
    this.errorMessage,
  });

  factory ServerReading.error(String message) {
    return ServerReading(
      co2: 0,
      temperature: 0.0,
      humidity: 0.0,
      updatedAt: '',
      timestamp: DateTime.now(),
      isSuccess: false,
      errorMessage: message,
    );
  }

  factory ServerReading.fromJson(Map<String, dynamic> json) {
    return ServerReading(
      co2: (json['co2'] as num?)?.toInt() ?? 0,
      temperature: ((json['temperature'] ?? json['temp']) as num?)?.toDouble() ?? 0.0,
      humidity: ((json['humidity'] ?? json['hum']) as num?)?.toDouble() ?? 0.0,
      updatedAt: json['updated_at']?.toString() ?? '',
      timestamp: DateTime.now(),
      isSuccess: true,
    );
  }
}

class ServerApiService {
  static final ServerApiService instance = ServerApiService._internal();
  ServerApiService._internal();

  String serverUrl = 'http://192.168.68.128:5000/api/data';

  Timer? _pollingTimer;
  final _readingController = StreamController<ServerReading>.broadcast();
  ServerReading? _lastReading;
  bool _isPolling = false;

  Stream<ServerReading> get readingStream => _readingController.stream;
  ServerReading? get lastReading => _lastReading;
  bool get isPolling => _isPolling;

  /// Spuštění automatického stahování dat ze serveru (výchozí interval 4 sekundy)
  void startAutoPolling({Duration interval = const Duration(seconds: 4)}) {
    _pollingTimer?.cancel();
    _isPolling = true;
    fetchLatest(); // První okamžité stažení
    _pollingTimer = Timer.periodic(interval, (_) => fetchLatest());
  }

  /// Zastavení automatického stahování
  void stopAutoPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isPolling = false;
  }

  /// Ruční stažení aktuálních dat z API
  Future<ServerReading> fetchLatest() async {
    try {
      final uri = Uri.parse(serverUrl);
      final response = await http.get(uri).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final reading = ServerReading.fromJson(decoded);
          _lastReading = reading;
          _readingController.add(reading);
          return reading;
        } else {
          final err = ServerReading.error('Neplatný formát JSON z API');
          _lastReading = err;
          _readingController.add(err);
          return err;
        }
      } else {
        final err = ServerReading.error('Chyba serveru HTTP ${response.statusCode}');
        _lastReading = err;
        _readingController.add(err);
        return err;
      }
    } catch (e) {
      final err = ServerReading.error('Nelze se spojit se serverem: $e');
      _lastReading = err;
      _readingController.add(err);
      return err;
    }
  }

  /// Volitelné odeslání testovacího záznamu na server (např. pro ověření funkčnosti)
  Future<bool> sendTestReading({required int co2, required double temp, required double hum}) async {
    try {
      final uri = Uri.parse(serverUrl);
      final body = jsonEncode({
        'co2': co2,
        'temperature': temp,
        'humidity': hum,
      });
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        await fetchLatest();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
