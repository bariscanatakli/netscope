import 'package:flutter_test/flutter_test.dart';
import 'package:netscope/screens/home/home_page.dart';
import 'package:netscope/screens/home/favorites_page.dart';
import 'package:netscope/screens/home/profile_page.dart';
import 'package:netscope/screens/home/root_screen.dart';
import 'package:netscope/services/network_info_service.dart';
import 'package:netscope/theme/theme_notifier.dart';

void main() {
  // This test imports all core feature files to ensure they're included in lcov.info
  test('Core features imports for coverage', () {
    expect(true, isTrue);
  });
}
