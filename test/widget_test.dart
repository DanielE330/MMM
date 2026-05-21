import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_finance/main.dart';

void main() {
  testWidgets('MMM app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MMM()));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
