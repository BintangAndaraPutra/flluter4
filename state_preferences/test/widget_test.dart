import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:state_preferences/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('theme preference and visit count persist between launches', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Jumlah kunjungan: 1'), findsOneWidget);
    expect(find.byTooltip('Mode gelap'), findsOneWidget);

    await tester.tap(find.byTooltip('Mode gelap'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Mode terang'), findsOneWidget);

    var prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('is_dark_mode'), isTrue);
    expect(prefs.getInt('visit_count'), 1);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Jumlah kunjungan: 2'), findsOneWidget);
    expect(find.byTooltip('Mode terang'), findsOneWidget);
    prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('visit_count'), 2);
  });

  testWidgets('user can save a profile and see it on the home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Selamat datang, Tamu!'), findsOneWidget);

    await tester.tap(find.text('Login / Daftar'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Nama'), 'Ayu');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'ayu@example.com',
    );
    await tester.tap(find.text('Simpan Profil'));
    await tester.pumpAndSettle();

    expect(find.text('Profil berhasil disimpan'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Selamat datang, Ayu!'), findsOneWidget);
    expect(find.text('Email: ayu@example.com'), findsOneWidget);
  });

  testWidgets('user can add and remove a persisted favorite', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Login / Daftar'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Tambah hobi atau favorit'),
      'Membaca',
    );
    await tester.ensureVisible(find.byTooltip('Tambah favorit'));
    await tester.tap(find.byTooltip('Tambah favorit'));
    await tester.pumpAndSettle();

    expect(find.text('Membaca'), findsOneWidget);
    var prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('favorites'), ['Membaca']);

    await tester.ensureVisible(find.byTooltip('Hapus Membaca'));
    await tester.tap(find.byTooltip('Hapus Membaca'));
    await tester.pumpAndSettle();
    expect(find.text('Membaca'), findsNothing);
    prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('favorites'), isEmpty);
  });

  testWidgets('profile rejects unsafe names and a previously used email', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'user_email': 'current@example.com',
      'used_emails': ['taken@example.com'],
    });

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Login / Daftar'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nama'),
      '<script>alert(1)</script>',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'taken@example.com',
    );
    await tester.tap(find.text('Simpan Profil'));
    await tester.pumpAndSettle();

    expect(
      find.text('Nama mengandung karakter yang tidak diizinkan'),
      findsOneWidget,
    );
    expect(find.text('Profil berhasil disimpan'), findsNothing);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Nama'), 'Ayu');
    await tester.tap(find.text('Simpan Profil'));
    await tester.pumpAndSettle();

    expect(find.text('Email sudah digunakan'), findsOneWidget);
    expect(find.text('Profil berhasil disimpan'), findsNothing);
  });
}
