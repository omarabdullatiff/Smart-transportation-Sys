class Trip {
  final String id;
  final String busId;
  final String route;
  final String departureTime;
  final String arrivalTime;
  final double price;
  final int availableSeats;
  final String status;
  final String driverName;
  final String busNumber;

  Trip({
    required this.id,
    required this.busId,
    required this.route,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    required this.availableSeats,
    required this.status,
    required this.driverName,
    required this.busNumber,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] ?? '',
      busId: json['busId'] ?? '',
      route: json['route'] ?? '',
      departureTime: json['departureTime'] ?? '',
      arrivalTime: json['arrivalTime'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      availableSeats: json['availableSeats'] ?? 0,
      status: json['status'] ?? '',
      driverName: json['driverName'] ?? '',
      busNumber: json['busNumber'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'busId': busId,
      'route': route,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'price': price,
      'availableSeats': availableSeats,
      'status': status,
      'driverName': driverName,
      'busNumber': busNumber,
    };
  }

  Trip copyWith({
    String? id,
    String? busId,
    String? route,
    String? departureTime,
    String? arrivalTime,
    double? price,
    int? availableSeats,
    String? status,
    String? driverName,
    String? busNumber,
  }) {
    return Trip(
      id: id ?? this.id,
      busId: busId ?? this.busId,
      route: route ?? this.route,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      price: price ?? this.price,
      availableSeats: availableSeats ?? this.availableSeats,
      status: status ?? this.status,
      driverName: driverName ?? this.driverName,
      busNumber: busNumber ?? this.busNumber,
    );
  }
} 