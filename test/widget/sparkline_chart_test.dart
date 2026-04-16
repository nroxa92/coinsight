import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coinsight/widgets/sparkline_chart.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  group('SparklineChart', () {
    testWidgets('renders without errors with valid data', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        SparklineChart(
          data: const [100, 101, 102, 103, 104],
          color: Colors.green,
        ),
      ));

      expect(find.byType(SparklineChart), findsOneWidget);
    });

    testWidgets('renders with empty data', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        SparklineChart(
          data: const [],
          color: Colors.green,
        ),
      ));

      expect(find.byType(SparklineChart), findsOneWidget);
    });

    testWidgets('renders with single data point', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        SparklineChart(
          data: const [100],
          color: Colors.red,
        ),
      ));

      expect(find.byType(SparklineChart), findsOneWidget);
    });
  });
}
