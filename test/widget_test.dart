import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thought_drop/main.dart';

void main() {
  testWidgets('App should build', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ThoughtDropApp(),
      ),
    );
    expect(find.text('thought_drop'), findsOneWidget);
  });
}
