// This is a basic Flutter widget test for CuckooBooru app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cuckoo_booru/main.dart';

void main() {
  testWidgets('CuckooBooru app loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const CuckooBooruApp());
    await tester.pumpAndSettle();

    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Search'), findsWidgets);
    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);
    expect(find.text('CuckooBooru'), findsOneWidget);
  });

  testWidgets('Navigation between tabs works', (WidgetTester tester) async {
    await tester.pumpWidget(const CuckooBooruApp());
    await tester.pumpAndSettle();

    expect(find.text('CuckooBooru'), findsOneWidget);

    final bottomNavBar = find.byType(BottomNavigationBar);
    expect(bottomNavBar, findsOneWidget);

    await tester.tap(
      find.descendant(of: bottomNavBar, matching: find.text('Favorites')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Favorites'), findsWidgets);

    await tester.tap(
      find.descendant(of: bottomNavBar, matching: find.text('About')),
    );
    await tester.pumpAndSettle();

    expect(find.text('About CuckooBooru'), findsOneWidget);

    await tester.tap(
      find.descendant(of: bottomNavBar, matching: find.text('Search')),
    );
    await tester.pumpAndSettle();

    expect(find.text('CuckooBooru'), findsOneWidget);
  });
}
