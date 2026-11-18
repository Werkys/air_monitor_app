import 'package:flutter_test/flutter_test.dart';
import 'package:air_monitor_app/main.dart';

void main() {
  testWidgets('App loads and renders title test', (WidgetTester tester) async {
    await tester.pumpWidget(const AirMonitorApp());
    expect(find.text('Sledování kvality ovzduší'), findsOneWidget);
  });
}
