// This is a basic Flutter widget test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:racpl/main.dart';
import 'package:racpl/utils/storage_helper.dart';

void main() {
  testWidgets('App initializes correctly', (WidgetTester tester) async {
    // Create a mock StorageHelper for testing
    final storage = StorageHelper();

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(storage: storage));

    // Verify the app is built successfully
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
