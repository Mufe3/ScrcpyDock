// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:scrcpydock/main.dart';

void main() {
  testWidgets('Scrcpy panel smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ScrcpyPremiumApp());

    // Verify that our panel title is present.
    expect(find.text('ScrcpyDock'), findsWidgets);

    // Verify conditional theme icon inline with brand name
    expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);

    // Toggle theme to light mode
    await tester.tap(find.byIcon(Icons.light_mode_outlined));
    await tester.pumpAndSettle();

    // Verify icon switches conditionally to dark_mode_outlined
    expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);

    // Toggle back to dark mode
    await tester.tap(find.byIcon(Icons.dark_mode_outlined));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);

    // Switch to Indonesian mode if default was English
    final isEnInitially = find.text('EN').evaluate().isNotEmpty;
    if (isEnInitially) {
      await tester.tap(find.text('EN'));
      await tester.pumpAndSettle();
      expect(find.text('ID'), findsOneWidget);
    }

    // Verify Tab Kontrol features (Orientation & Live Recording)
    expect(find.text('KONTROL LAYAR & ROTASI'), findsOneWidget);
    expect(find.text('Auto-Rotate'), findsOneWidget);
    expect(find.text('Tegak (0°)'), findsOneWidget);
    expect(find.text('Mendatar (90°)'), findsOneWidget);
    expect(find.text('Rekam Layar'), findsOneWidget);

    // Test tapping orientation chip
    await tester.tap(find.text('Mendatar (90°)'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Auto-Rotate'));
    await tester.pumpAndSettle();

    // Verify Mode Operasi in Tab Kontrol
    expect(find.text('MODE OPERASI (1-KLIK)'), findsOneWidget);
    expect(find.text('Webcam'), findsOneWidget);
    expect(find.text('Mic'), findsOneWidget);
    expect(find.text('OTG'), findsOneWidget);

    // Switch to OTG mode in Tab Kontrol
    await tester.tap(find.text('OTG'));
    await tester.pumpAndSettle();

    // Verify OTG Hardware HID Deck
    expect(find.text('Kontrol Hardware OTG'), findsOneWidget);
    expect(find.text('Mouse Bebas (PC & HP)'), findsOneWidget);
    expect(find.text('Mouse Kunci (Game FPS)'), findsOneWidget);
    expect(find.text('Ke Layar'), findsOneWidget);

    // Switch to Game FPS mode
    await tester.tap(find.text('Mouse Kunci (Game FPS)'));
    await tester.pumpAndSettle();
    expect(find.text('Mouse Kunci (Game FPS)'), findsOneWidget);
    expect(find.text('Tekan tombol Left Alt untuk melepas kursor'), findsOneWidget);

    // Switch to Webcam mode to verify Webcam HP card
    await tester.tap(find.text('Webcam'));
    await tester.pumpAndSettle();
    expect(find.text('Webcam HP'), findsOneWidget);

    // Switch back to Screen mode via Ke Layar
    await tester.tap(find.text('Ke Layar'));
    await tester.pumpAndSettle();

    // Switch to Tab Kualitas
    await tester.tap(find.text('Kualitas'));
    await tester.pumpAndSettle();

    // Verify automatic behavior options in Tab Kualitas
    expect(find.text('RESOLUSI TAMPILAN'), findsOneWidget);
    expect(find.text('FRAME RATE (MAX FPS)'), findsOneWidget);
    expect(find.text('BITRATE STREAMING'), findsOneWidget);
    expect(find.text('CODEC VIDEO'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Audio to PC'), 100);
    expect(find.text('Turn screen off'), findsOneWidget);
    expect(find.text('Always on top'), findsOneWidget);
    expect(find.text('Audio to PC'), findsOneWidget);
    expect(find.text('Stay awake'), findsOneWidget);

    // Scroll back to top before switching tab
    await tester.scrollUntilVisible(find.text('RESOLUSI TAMPILAN'), -100);

    // Switch to Tab Macro (MacroDock Studio)
    await tester.tap(find.text('Makro'));
    await tester.pumpAndSettle();

    expect(find.text('Rekam (REC)'), findsOneWidget);
    expect(find.text('Putar (PLAY)'), findsOneWidget);
    expect(find.text('JUMLAH LOOP'), findsOneWidget);
    expect(find.text('KECEPATAN'), findsOneWidget);
    expect(find.text('URUTAN LANGKAH (0)'), findsOneWidget);
    expect(find.text('Studio Rekam Makro Siap'), findsOneWidget);

    // Tap Rekam (REC) button to verify state toggle
    await tester.tap(find.text('Rekam (REC)'));
    await tester.pumpAndSettle();
    expect(find.text('Stop Rekam'), findsOneWidget);

    // Test Multi-Runner toggle
    expect(find.text('Device Aktif'), findsOneWidget);
    expect(find.text('Multi-Runner (0)'), findsOneWidget);

    await tester.tap(find.text('Multi-Runner (0)'));
    await tester.pumpAndSettle();
    expect(find.text('Putar Semua'), findsOneWidget);
    expect(find.text('Stop Semua'), findsOneWidget);
    expect(find.byIcon(Icons.folder_open_rounded), findsOneWidget);
    expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
    expect(find.text('Belum Ada Perangkat Terhubung'), findsOneWidget);

    await tester.tap(find.text('Device Aktif'));
    await tester.pumpAndSettle();
    expect(find.text('Studio Rekam Makro Siap'), findsOneWidget);

    // Switch to Tab Device (Wireless Hub)
    await tester.tap(find.text('Perangkat'));
    await tester.pumpAndSettle();
    expect(find.text('Pusat Sambungan Wi-Fi'), findsOneWidget);
    expect(find.text('Kode QR'), findsOneWidget);
    expect(find.text('Auto USB'), findsOneWidget);
    expect(find.text('Pair A11+'), findsOneWidget);
    expect(find.text('Manual IP'), findsOneWidget);
    expect(find.text('Scan Net'), findsOneWidget);

    // Test switching Wi-Fi tabs
    await tester.tap(find.text('Auto USB'));
    await tester.pumpAndSettle();
    expect(find.text('Aktifkan Wi-Fi (1-Klik)'), findsOneWidget);

    await tester.tap(find.text('Manual IP'));
    await tester.pumpAndSettle();
    expect(find.text('Sambungkan ke IP Ini'), findsOneWidget);

    await tester.tap(find.text('Pair A11+'));
    await tester.pumpAndSettle();
    expect(find.text('Pasangkan & Sambungkan'), findsOneWidget);

    await tester.tap(find.text('Scan Net'));
    await tester.pumpAndSettle();
    expect(find.text('Pindai Perangkat (mDNS & Port)'), findsOneWidget);

    // Switch back to Kode QR
    await tester.tap(find.text('Kode QR'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Acak PIN'), findsOneWidget);

    // Switch to Tab About
    await tester.tap(find.text('Tentang'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('ScrcpyDock'), findsWidgets);
    expect(find.text('v1.0.0'), findsOneWidget);
    expect(find.text('Donasi'), findsOneWidget);
    expect(find.text('Rekaman'), findsOneWidget);

    // Open Clean Donation Dialog in Indonesian mode
    await tester.tap(find.text('Donasi'));
    await tester.pumpAndSettle();
    expect(find.text('Dukungan Donasi'), findsOneWidget);
    expect(find.text('Buka Saweria'), findsOneWidget);

    // Close Dialog
    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();

    // Now test switching back to English mode
    await tester.tap(find.text('ID'));
    await tester.pumpAndSettle();
    expect(find.text('EN'), findsOneWidget);
    expect(find.text('Donate'), findsOneWidget);
    expect(find.text('Recordings'), findsOneWidget);

    // Open Clean Donation Dialog in English mode
    await tester.tap(find.text('Donate'));
    await tester.pumpAndSettle();
    expect(find.text('Support Developer'), findsOneWidget);
    expect(find.text('Open Saweria'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);

    // Close Dialog
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    // Verify Device tab in English mode
    await tester.tap(find.text('Device'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('DEVICE LIST (0)'), findsOneWidget);
    expect(find.text('Rescan'), findsOneWidget);
    expect(find.text('Wi-Fi Connection Hub'), findsOneWidget);
    expect(find.text('QR Code'), findsOneWidget);
  });
}
