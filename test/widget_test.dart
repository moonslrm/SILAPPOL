import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:silappol_app/app.dart';

void main() {
  testWidgets('app boots with SILAPPOL home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SilappolApp());
    await tester.pumpAndSettle();

    expect(find.text('SILAPPOL'), findsWidgets);
    expect(find.byType(Scaffold), findsWidgets);
  });
}
