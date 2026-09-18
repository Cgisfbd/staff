import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/features/dashboard/domain/models/occasion_banner.dart';
import 'package:staff_app/features/dashboard/presentation/widgets/occasion_banner_card.dart';

void main() {
  setUp(() => TestWidgetsFlutterBinding.ensureInitialized());

  const sampleBanner = OccasionBanner(
    id: 'test_banner',
    title: 'Eid Mubarak & Annual Notice',
    subtitle: 'Warm wishes to all teachers and staff members from management.',
    badge: 'SPECIAL OCCASION',
    imagePath: 'assets/images/banner.png',
  );

  group('OccasionBannerCard Test Suite', () {
    const testSizes = [
      Size(320, 568), // 320dp narrow phone
      Size(360, 640), // Budget Android
      Size(393, 852), // Flagship phone
      Size(600, 1024), // Tablet
    ];

    for (final size in testSizes) {
      testWidgets('Renders with 0-overflow on ${size.width}x${size.height}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: OccasionBannerCard(
                banners: [sampleBanner],
              ),
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.text('Eid Mubarak & Annual Notice'), findsOneWidget);
        expect(find.text('SPECIAL OCCASION'), findsOneWidget);
      });
    }

    testWidgets('Returns SizedBox.shrink() when banners list is empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OccasionBannerCard(
              banners: [],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(OccasionBannerCard), findsOneWidget);
      expect(find.text('Eid Mubarak & Annual Notice'), findsNothing);
    });

    testWidgets('Does not show close button when isDismissible is false (default)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OccasionBannerCard(
              banners: [sampleBanner],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.close_rounded), findsNothing);
    });

    testWidgets('Tapping close button triggers onDismiss callback when isDismissible is true', (tester) async {
      String? dismissedId;

      const dismissibleBanner = OccasionBanner(
        id: 'dismiss_banner',
        title: 'Dismissible Notice',
        badge: 'NOTICE',
        isDismissible: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OccasionBannerCard(
              banners: const [dismissibleBanner],
              onDismiss: (id) => dismissedId = id,
            ),
          ),
        ),
      );
      await tester.pump();

      final closeButton = find.byIcon(Icons.close_rounded);
      expect(closeButton, findsOneWidget);

      await tester.tap(closeButton);
      await tester.pump();

      expect(dismissedId, 'dismiss_banner');
    });

    testWidgets('Renders animated dots when multiple banners are present', (tester) async {
      const banner2 = OccasionBanner(
        id: 'banner_2',
        title: 'Second Banner Notice',
        badge: 'EVENTS',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OccasionBannerCard(
              banners: [sampleBanner, banner2],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(AnimatedContainer), findsWidgets);
    });
  });
}
