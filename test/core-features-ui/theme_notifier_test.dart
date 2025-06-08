import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netscope/theme/theme_notifier.dart';
import 'package:netscope/theme/app_theme.dart';

void main() {
  group('ThemeNotifier', () {
    late ThemeNotifier themeNotifier;

    setUp(() {
      themeNotifier = ThemeNotifier();
    });

    group('Initialization', () {
      test('should initialize with dark theme by default', () {
        expect(themeNotifier.currentTheme.brightness, Brightness.dark);
      });

      test('should be a ChangeNotifier', () {
        expect(themeNotifier, isA<ChangeNotifier>());
      });

      test('currentTheme getter should return the current theme', () {
        final currentTheme = themeNotifier.currentTheme;
        expect(currentTheme, isNotNull);
        expect(currentTheme, isA<ThemeData>());
      });
    });

    group('Theme Toggling', () {
      test('should toggle from dark to light theme', () {
        // Initially dark theme
        expect(themeNotifier.currentTheme.brightness, Brightness.dark);

        // Toggle to light
        themeNotifier.toggleTheme();

        expect(themeNotifier.currentTheme.brightness, Brightness.light);
      });

      test('should toggle from light to dark theme', () {
        // Start with dark, toggle to light first
        themeNotifier.toggleTheme();
        expect(themeNotifier.currentTheme.brightness, Brightness.light);

        // Now toggle back to dark
        themeNotifier.toggleTheme();

        expect(themeNotifier.currentTheme.brightness, Brightness.dark);
      });

      test('should toggle themes multiple times correctly', () {
        // Initial state: dark
        expect(themeNotifier.currentTheme.brightness, Brightness.dark);

        // Toggle 1: dark -> light
        themeNotifier.toggleTheme();
        expect(themeNotifier.currentTheme.brightness, Brightness.light);

        // Toggle 2: light -> dark
        themeNotifier.toggleTheme();
        expect(themeNotifier.currentTheme.brightness, Brightness.dark);

        // Toggle 3: dark -> light
        themeNotifier.toggleTheme();
        expect(themeNotifier.currentTheme.brightness, Brightness.light);

        // Toggle 4: light -> dark
        themeNotifier.toggleTheme();
        expect(themeNotifier.currentTheme.brightness, Brightness.dark);
      });
    });

    group('Listener Notifications', () {
      test('should notify listeners when theme is toggled', () {
        int notificationCount = 0;

        // Add listener
        themeNotifier.addListener(() {
          notificationCount++;
        });

        // Initial count should be 0
        expect(notificationCount, 0);

        // Toggle theme - should notify listeners
        themeNotifier.toggleTheme();
        expect(notificationCount, 1);

        // Toggle again - should notify again
        themeNotifier.toggleTheme();
        expect(notificationCount, 2);
      });

      test('should notify multiple listeners when theme is toggled', () {
        int listener1Count = 0;
        int listener2Count = 0;
        int listener3Count = 0;

        // Add multiple listeners
        themeNotifier.addListener(() => listener1Count++);
        themeNotifier.addListener(() => listener2Count++);
        themeNotifier.addListener(() => listener3Count++);

        // Toggle theme - all listeners should be notified
        themeNotifier.toggleTheme();

        expect(listener1Count, 1);
        expect(listener2Count, 1);
        expect(listener3Count, 1);

        // Toggle again - all listeners should be notified again
        themeNotifier.toggleTheme();

        expect(listener1Count, 2);
        expect(listener2Count, 2);
        expect(listener3Count, 2);
      });

      test('should not notify listeners after they are removed', () {
        int notificationCount = 0;

        void listener() {
          notificationCount++;
        }

        // Add listener
        themeNotifier.addListener(listener);

        // Toggle - should notify
        themeNotifier.toggleTheme();
        expect(notificationCount, 1);

        // Remove listener
        themeNotifier.removeListener(listener);

        // Toggle again - should not notify removed listener
        themeNotifier.toggleTheme();
        expect(notificationCount, 1); // Still 1, not 2
      });
    });

    group('Theme State Consistency', () {
      test('currentTheme should always match expected theme after toggle', () {
        // Verify initial state
        expect(themeNotifier.currentTheme.brightness, Brightness.dark);

        // Toggle and verify
        themeNotifier.toggleTheme();
        expect(themeNotifier.currentTheme.brightness, Brightness.light);

        // Toggle back and verify
        themeNotifier.toggleTheme();
        expect(themeNotifier.currentTheme.brightness, Brightness.dark);
      });

      test('theme should have light theme properties when brightness is light', () {
        themeNotifier.toggleTheme(); // Switch to light

        expect(themeNotifier.currentTheme.brightness, Brightness.light);
        expect(themeNotifier.currentTheme.useMaterial3, true);
        expect(themeNotifier.currentTheme.visualDensity, VisualDensity.adaptivePlatformDensity);
      });

      test('theme should have dark theme properties when brightness is dark', () {
        // Already starts with dark theme
        expect(themeNotifier.currentTheme.brightness, Brightness.dark);
        expect(themeNotifier.currentTheme.useMaterial3, true);
        expect(themeNotifier.currentTheme.visualDensity, VisualDensity.adaptivePlatformDensity);

        // Toggle to light then back to dark
        themeNotifier.toggleTheme();
        themeNotifier.toggleTheme();

        expect(themeNotifier.currentTheme.brightness, Brightness.dark);
        expect(themeNotifier.currentTheme.useMaterial3, true);
        expect(themeNotifier.currentTheme.visualDensity, VisualDensity.adaptivePlatformDensity);
      });
    });

    group('Edge Cases', () {
      test('should handle rapid theme toggling', () {
        expect(themeNotifier.currentTheme.brightness, Brightness.dark);

        // Rapid toggles
        for (int i = 0; i < 10; i++) {
          themeNotifier.toggleTheme();
        }

        // After even number of toggles (10), should be back to original (dark)
        expect(themeNotifier.currentTheme.brightness, Brightness.dark);
      });

      test('should maintain listener functionality after multiple toggles', () {
        int notificationCount = 0;
        themeNotifier.addListener(() => notificationCount++);

        // Multiple toggles
        for (int i = 0; i < 5; i++) {
          themeNotifier.toggleTheme();
        }

        expect(notificationCount, 5);
      });
    });

    group('Memory Management', () {
      test('should properly dispose without errors', () {
        int notificationCount = 0;
        themeNotifier.addListener(() => notificationCount++);

        // Toggle before disposal
        themeNotifier.toggleTheme();
        expect(notificationCount, 1);

        // Dispose should not throw errors
        expect(() => themeNotifier.dispose(), returnsNormally);
      });
    });

    tearDown(() {
      // Only dispose if not already disposed
      if (themeNotifier.hasListeners || !themeNotifier.hasListeners) {
        try {
          themeNotifier.dispose();
        } catch (e) {
          // Already disposed, ignore
        }
      }
    });
  });
}