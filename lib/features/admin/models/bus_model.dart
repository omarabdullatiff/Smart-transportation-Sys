import 'package:flutter/material.dart';

class Bus {
  final int id;
  final String licensePlate;
  final String model;
  final int capacity;
  final String status;
  final String origin;
  final String destination;

  const Bus({
    required this.id,
    required this.licensePlate,
    required this.model,
    required this.capacity,
    required this.status,
    required this.origin,
    required this.destination,
  });

  factory Bus.fromJson(Map<String, dynamic> json) {
    return Bus(
      id: json['id'] as int,
      licensePlate: json['licensePlate'] as String,
      model: json['model'] as String,
      capacity: json['capacity'] as int,
      status: json['status'] as String,
      origin: json['origin'] as String,
      destination: json['destination'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'licensePlate': licensePlate,
      'model': model,
      'capacity': capacity,
      'status': status,
      'origin': origin,
      'destination': destination,
    };
  }
}

enum BusStatus {
  active('Active', 0),
  outOfService('Out of Service', 1),
  maintenance('Maintenance', 2),
  inactive('Inactive', 3); // For backward compatibility

  const BusStatus(this.stringValue, this.intValue);
  final String stringValue;
  final int intValue;

  static BusStatus fromValue(String value) {
    return BusStatus.values.firstWhere(
      (status) => status.stringValue.toLowerCase() == value.toLowerCase(),
      orElse: () => BusStatus.inactive,
    );
  }

  static BusStatus fromIntValue(int value) {
    return BusStatus.values.firstWhere(
      (status) => status.intValue == value,
      orElse: () => BusStatus.inactive,
    );
  }
}

extension BusExtension on Bus {
  BusStatus get busStatus => BusStatus.fromValue(status);
  
  Color get statusColor {
    switch (busStatus) {
      case BusStatus.active:
        return Colors.green;
      case BusStatus.inactive:
        return Colors.grey;
      case BusStatus.maintenance:
        return Colors.orange;
      case BusStatus.outOfService:
        return Colors.red;
    }
  }

  String get route => '$origin → $destination';

  // Get integer status value for API calls
  int get statusIntValue => busStatus.intValue;
} 