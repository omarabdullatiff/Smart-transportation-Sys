import 'package:flutter/material.dart';

class Driver {
  final int id;
  final String name;
  final String phoneNumber;
  final String licenseNumber;
  final int status;

  const Driver({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.licenseNumber,
    required this.status,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] as int,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      licenseNumber: json['licenseNumber'] as String,
      status: json['status'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'licenseNumber': licenseNumber,
      'status': status,
    };
  }
}

class DriverLocation {
  final double latitude;
  final double longitude;
  final DateTime? timestamp;

  const DriverLocation({
    required this.latitude,
    required this.longitude,
    this.timestamp,
  });

  factory DriverLocation.fromJson(Map<String, dynamic> json) {
    return DriverLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timestamp: json['timestamp'] != null 
          ? DateTime.tryParse(json['timestamp'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
    };
  }
}

enum DriverStatus {
  available(0),
  driving(1),
  offline(2);

  const DriverStatus(this.value);
  final int value;

  static DriverStatus fromValue(int value) {
    return DriverStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => DriverStatus.offline,
    );
  }
}

extension DriverExtension on Driver {
  DriverStatus get driverStatus => DriverStatus.fromValue(status);
  
  String get statusText {
    switch (driverStatus) {
      case DriverStatus.available:
        return 'Available';
      case DriverStatus.driving:
        return 'Driving';
      case DriverStatus.offline:
        return 'Offline';
    }
  }
  
  Color get statusColor {
    switch (driverStatus) {
      case DriverStatus.available:
        return Colors.green;
      case DriverStatus.driving:
        return Colors.blue;
      case DriverStatus.offline:
        return Colors.grey;
    }
  }
} 