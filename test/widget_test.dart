import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/screens/physio/physio_dashboard.dart';

void main() {
  testWidgets('app renders physio dashboard FAB', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: PhysioDashboard()));

    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
