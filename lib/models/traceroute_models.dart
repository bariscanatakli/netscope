import 'package:flutter/material.dart';

class TracerouteHop {
  final int hopNumber;
  final String address;
  final double responseTime;
  final Map<String, dynamic> geolocation;
  final bool isSuccess;

  TracerouteHop({
    required this.hopNumber,
    required this.address,
    required this.responseTime,
    required this.geolocation,
    this.isSuccess = true,
  });

  TracerouteHop copyWith({
    int? hopNumber,
    String? address,
    double? responseTime,
    Map<String, dynamic>? geolocation,
    bool? isSuccess,
  }) {
    return TracerouteHop(
      hopNumber: hopNumber ?? this.hopNumber,
      address: address ?? this.address,
      responseTime: responseTime ?? this.responseTime,
      geolocation: geolocation ?? this.geolocation,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hopNumber': hopNumber,
      'address': address,
      'responseTime': responseTime,
      'geolocation': geolocation,
      'isSuccess': isSuccess,
    };
  }

  factory TracerouteHop.fromMap(Map<String, dynamic> map) {
    return TracerouteHop(
      hopNumber: map['hopNumber'] ?? 0,
      address: map['address'] ?? '',
      responseTime: (map['responseTime'] ?? 0.0).toDouble(),
      geolocation: Map<String, dynamic>.from(map['geolocation'] ?? {}),
      isSuccess: map['isSuccess'] ?? true,
    );
  }
}

class TracerouteResult {
  final List<TracerouteHop> hops;
  final DateTime timestamp;
  final String destination;
  final String sourceIp;

  TracerouteResult({
    required this.hops,
    required this.timestamp,
    required this.destination,
    required this.sourceIp,
  });

  Map<String, dynamic> toMap() {
    return {
      'hops': hops.map((hop) => hop.toMap()).toList(),
      'timestamp': timestamp,
      'destination': destination,
      'sourceIp': sourceIp,
    };
  }

  factory TracerouteResult.fromMap(Map<String, dynamic> map) {
    DateTime ts;
    final t = map['timestamp'];
    if (t is DateTime) {
      ts = t;
    } else if (t != null && t.toString().contains('Timestamp')) {
      ts = t.toDate();
    } else {
      ts = DateTime.now();
    }
    return TracerouteResult(
      hops: List<TracerouteHop>.from(
          (map['hops'] ?? []).map((x) => TracerouteHop.fromMap(x))),
      timestamp: ts,
      destination: map['destination'] ?? '',
      sourceIp: map['sourceIp'] ?? '',
    );
  }
}
