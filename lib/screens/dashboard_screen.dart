import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/air_data_point.dart';
import '../services/air_quality_service.dart';
import '../services/server_api_service.dart';
import '../widgets/interactive_chart.dart';
import '../widgets/metric_card.dart';
import '../widgets/period_selector.dart';
import '../widgets/traffic_light_badge.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  PeriodType _selectedPeriod = PeriodType.week;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  int _liveCo2 = 765;
  double _liveTemp = 21.8;
  double _liveHum = 44.5;
  DateTime _lastMeasurementTime = DateTime.now();

  bool _isServerConnected = false;
  String? _serverError;
  String? _sensorError;

  final List<AirDataPoint> _liveDataBuffer = [];
  StreamSubscription? _serverSub;

  @override
  void initState() {
    super.initState();
    _initServerAutoPolling();
  }

  void _initServerAutoPolling() {
    final server = ServerApiService.instance;
    server.startAutoPolling(interval: const Duration(seconds: 4));

    _serverSub = server.readingStream.listen((reading) {
      if (!mounted) return;
      setState(() {
        if (reading.isSuccess) {
          _isServerConnected = true;
          _serverError = null;

          if (reading.co2 > 0) {
            _liveCo2 = reading.co2;
            _liveTemp = reading.temperature;
            _liveHum = reading.humidity;
            _lastMeasurementTime = reading.timestamp;

            if (_liveDataBuffer.isEmpty ||
                _liveDataBuffer.last.co2 != reading.co2 ||
                _liveDataBuffer.last.temperature != reading.temperature) {
              _liveDataBuffer.add(
                AirDataPoint(
                  timestamp: reading.timestamp,
                  co2: reading.co2,
                  temperature: reading.temperature,
                  humidity: reading.humidity,
                ),
              );
            }
          }
        } else {
          _isServerConnected = false;
          _serverError = reading.errorMessage;
        }
      });
    });
  }

  @override
  void dispose() {
    _serverSub?.cancel();
    ServerApiService.instance.stopAutoPolling();
    super.dispose();
  }

  Future<void> _refreshServerData() async {
    final reading = await ServerApiService.instance.fetchLatest();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            reading.isSuccess
                ? 'Data načtena ze serveru: ${reading.co2} ppm'
                : 'Chyba serveru: ${reading.errorMessage}',
          ),
          backgroundColor: reading.isSuccess ? const Color(0xFF0087CD) : const Color(0xFFDC2626),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  List<AirDataPoint> _getCurrentData() {
    List<AirDataPoint> baseData;
    switch (_selectedPeriod) {
      case PeriodType.week:
        baseData = AirQualityService.getWeekData('stcc4-main');
        break;
      case PeriodType.month:
        baseData = AirQualityService.getMonthData('stcc4-main', _selectedYear, _selectedMonth);
        break;
      case PeriodType.year:
        baseData = AirQualityService.getYearData('stcc4-main', _selectedYear);
        break;
    }

    if (_liveDataBuffer.isEmpty) {
      return baseData;
    }

    return [...baseData, ..._liveDataBuffer];
  }

  @override
  Widget build(BuildContext context) {
    final data = _getCurrentData();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        toolbarHeight: 56,
        backgroundColor: const Color(0xFF0087CD),
        title: const Text(
          'Sledování kvality ovzduší',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 9,
                  height: 9,
                  color: _isServerConnected ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                ),
                const SizedBox(width: 6),
                Text(
                  _isServerConnected ? 'SERVER ONLINE' : 'SERVER OFFLINE',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.refresh_sharp, color: Colors.white, size: 20),
                  tooltip: 'Obnovit data ze serveru',
                  onPressed: _refreshServerData,
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_serverError != null) ...[
              _buildAlertBox('CHYBA PŘIPOJENÍ K SERVERU', _serverError!),
              const SizedBox(height: 14),
            ],
            if (_sensorError != null) ...[
              _buildAlertBox('VAROVÁNÍ MĚŘICÍ SONDY', _sensorError!),
              const SizedBox(height: 14),
            ],

            // Aktuální naměřené hodnoty
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: MetricCard(
                    title: 'Aktuální oxid uhličitý',
                    value: '$_liveCo2',
                    unit: 'ppm',
                    accentColor: const Color(0xFF0087CD),
                    subtitle: 'Aktualizováno: ${DateFormat('HH:mm:ss').format(_lastMeasurementTime)}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: MetricCard(
                    title: 'Aktuální teplota',
                    value: _liveTemp.toStringAsFixed(1),
                    unit: '°C',
                    accentColor: const Color(0xFF059669),
                    subtitle: 'Optimum: 20 – 24 °C',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: MetricCard(
                    title: 'Relativní vlhkost',
                    value: _liveHum.toStringAsFixed(0),
                    unit: '% RH',
                    accentColor: const Color(0xFF0284C7),
                    subtitle: 'Optimum: 40 – 60 %',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Indikátor stavu místnosti (semafor)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFD9D9D9)),
              ),
              child: Row(
                children: [
                  const Text(
                    'STAV MÍSTNOSTI:',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                  const Spacer(),
                  TrafficLightBadge(co2: _liveCo2),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Volič období
            PeriodSelector(
              currentPeriod: _selectedPeriod,
              selectedMonth: _selectedMonth,
              selectedYear: _selectedYear,
              onPeriodChanged: (period) => setState(() => _selectedPeriod = period),
              onMonthChanged: (m) => setState(() => _selectedMonth = m),
              onYearChanged: (y) => setState(() => _selectedYear = y),
            ),

            const SizedBox(height: 14),

            // Graf průběhu CO2
            AirQualityChart(dataPoints: data),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertBox(String title, String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        border: Border.all(color: const Color(0xFFB71C1C), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFFB71C1C),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            message,
            style: const TextStyle(fontSize: 12, color: Color(0xFF7F1D1D)),
          ),
        ],
      ),
    );
  }
}
