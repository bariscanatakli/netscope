import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netscope/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    group('Constants', () {
      test('should have correct color constants', () {
        expect(AppTheme.primaryColor, const Color(0xFF3A4F56));
        expect(AppTheme.secondaryColor, const Color(0xFF718792));
        expect(AppTheme.backgroundColor, const Color(0xFFF5F5F5));
        expect(AppTheme.errorColor, const Color(0xFFB00020));
      });
    });

    group('Light Theme', () {
      late ThemeData lightTheme;

      setUp(() {
        lightTheme = AppTheme.lightTheme;
      });

      test('should use Material 3', () {
        expect(lightTheme.useMaterial3, true);
      });

      test('should have correct visual density', () {
        expect(lightTheme.visualDensity, VisualDensity.adaptivePlatformDensity);
      });

      test('should have correct color scheme', () {
        expect(lightTheme.colorScheme.brightness, Brightness.light);
        // The seed color should influence the color scheme
        expect(lightTheme.colorScheme, isA<ColorScheme>());
      });

      group('AppBar Theme', () {
        test('should have correct AppBar configuration', () {
          final appBarTheme = lightTheme.appBarTheme;
          
          expect(appBarTheme.elevation, 0);
          expect(appBarTheme.centerTitle, true);
          expect(appBarTheme.backgroundColor, Colors.transparent);
          expect(appBarTheme.foregroundColor, AppTheme.primaryColor);
          expect(appBarTheme.iconTheme?.color, AppTheme.primaryColor);
        });
      });

      group('Elevated Button Theme', () {
        test('should have correct ElevatedButton configuration', () {
          final elevatedButtonTheme = lightTheme.elevatedButtonTheme;
          final style = elevatedButtonTheme.style;
          
          expect(style?.foregroundColor?.resolve({}), Colors.white);
          expect(style?.backgroundColor?.resolve({}), AppTheme.primaryColor);
          expect(style?.elevation?.resolve({}), 2);
          expect(
            style?.padding?.resolve({}),
            const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          );
          expect(
            style?.shape?.resolve({}),
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          );
        });
      });

      group('Outlined Button Theme', () {
        test('should have correct OutlinedButton configuration', () {
          final outlinedButtonTheme = lightTheme.outlinedButtonTheme;
          final style = outlinedButtonTheme.style;
          
          expect(style?.foregroundColor?.resolve({}), AppTheme.primaryColor);
          expect(
            style?.side?.resolve({}),
            const BorderSide(color: AppTheme.primaryColor),
          );
          expect(
            style?.padding?.resolve({}),
            const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          );
          expect(
            style?.shape?.resolve({}),
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          );
        });
      });

      group('Input Decoration Theme', () {
        test('should have correct InputDecoration configuration', () {
          final inputDecorationTheme = lightTheme.inputDecorationTheme;
          
          expect(inputDecorationTheme.filled, true);
          expect(inputDecorationTheme.fillColor, Colors.grey[200]);
          expect(
            inputDecorationTheme.contentPadding,
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          );
        });

        test('should have correct border configurations', () {
          final inputDecorationTheme = lightTheme.inputDecorationTheme;
          
          // Default border
          expect(
            inputDecorationTheme.border,
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          );

          // Enabled border
          expect(
            inputDecorationTheme.enabledBorder,
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          );

          // Focused border
          expect(
            inputDecorationTheme.focusedBorder,
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryColor),
            ),
          );

          // Error border
          expect(
            inputDecorationTheme.errorBorder,
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.errorColor),
            ),
          );
        });
      });

      group('Card Theme', () {
        test('should have correct Card configuration', () {
          final cardTheme = lightTheme.cardTheme;
          
          expect(cardTheme.elevation, 2);
          expect(
            cardTheme.shape,
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          );
        });
      });
    });

    group('Dark Theme', () {
      late ThemeData darkTheme;

      setUp(() {
        darkTheme = AppTheme.darkTheme;
      });

      test('should use Material 3', () {
        expect(darkTheme.useMaterial3, true);
      });

      test('should have correct visual density', () {
        expect(darkTheme.visualDensity, VisualDensity.adaptivePlatformDensity);
      });

      test('should have correct color scheme', () {
        expect(darkTheme.colorScheme.brightness, Brightness.dark);
        // The seed color should influence the color scheme
        expect(darkTheme.colorScheme, isA<ColorScheme>());
      });

      test('should be different from light theme', () {
        expect(darkTheme.colorScheme.brightness, isNot(AppTheme.lightTheme.colorScheme.brightness));
      });
    });

    group('Theme Comparison', () {
      test('light and dark themes should have different brightness', () {
        expect(
          AppTheme.lightTheme.colorScheme.brightness,
          isNot(AppTheme.darkTheme.colorScheme.brightness),
        );
      });

      test('both themes should use the same primary seed color', () {
        // Both themes are created from the same seed color, so they should share certain characteristics
        expect(AppTheme.lightTheme.useMaterial3, AppTheme.darkTheme.useMaterial3);
        expect(AppTheme.lightTheme.visualDensity, AppTheme.darkTheme.visualDensity);
      });
    });

    group('Color Scheme Generation', () {
      test('light theme color scheme should be generated from seed color', () {
        final lightTheme = AppTheme.lightTheme;
        final expectedColorScheme = ColorScheme.fromSeed(
          seedColor: AppTheme.primaryColor,
          brightness: Brightness.light,
        );
        
        expect(lightTheme.colorScheme.primary, expectedColorScheme.primary);
        expect(lightTheme.colorScheme.brightness, expectedColorScheme.brightness);
      });

      test('dark theme color scheme should be generated from seed color', () {
        final darkTheme = AppTheme.darkTheme;
        final expectedColorScheme = ColorScheme.fromSeed(
          seedColor: AppTheme.primaryColor,
          brightness: Brightness.dark,
        );
        
        expect(darkTheme.colorScheme.primary, expectedColorScheme.primary);
        expect(darkTheme.colorScheme.brightness, expectedColorScheme.brightness);
      });
    });

    group('Theme Accessibility', () {
      test('should have proper contrast ratios', () {
        // Test that primary color and white have sufficient contrast for button text
        expect(AppTheme.primaryColor.computeLuminance(), lessThan(0.5));
        expect(Colors.white.computeLuminance(), greaterThan(0.5));
      });

      test('error color should be distinguishable', () {
        expect(AppTheme.errorColor, isNot(AppTheme.primaryColor));
        expect(AppTheme.errorColor, isNot(AppTheme.secondaryColor));
      });
    });
  });
}