// test/mocks/http_overrides.dart

import 'dart:async';
import 'dart:io';

/// A custom IOOverrides that forces all `InternetAddress.lookup(...)` calls
/// to go through our provided `customLookup` instead of doing a real DNS lookup.
class TestIOOverrides extends IOOverrides {
  /// `customLookup(host)` should return a `Future<List<InternetAddress>>` or throw.
  final Future<List<InternetAddress>> Function(String host) customLookup;

  TestIOOverrides({required this.customLookup});

  @override
  Future<List<InternetAddress>> lookup(
    String host, {
    InternetAddressType type = InternetAddressType.any,
  }) {
    // Instead of a real DNS lookup, call our custom function:
    return customLookup(host);
  }
}

/// Two convenience functions for “force‐success” or “force‐failure”:
class TestInternetAddress {
  /// Force DNS to succeed: return a non‐empty list with a dummy address.
  static Future<List<InternetAddress>> succeed(String host) async {
    return [InternetAddress('127.0.0.1')];
  }

  /// Force DNS to throw a SocketException.
  static Future<List<InternetAddress>> fail(String host) {
    throw const SocketException('Simulated no‐network');
  }
}
