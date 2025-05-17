class LostItem {
  final String description;
  final DateTime dateLost;
  final String busNumber;
  final String contactName;
  final String contactPhone;
  final String? photoUrl;

  LostItem({
    required this.description,
    required this.dateLost,
    required this.busNumber,
    required this.contactName,
    required this.contactPhone,
    this.photoUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'dateLost': dateLost.toIso8601String(),
      'busNumber': busNumber,
      'contactName': contactName,
      'contactPhone': contactPhone,
      'photoUrl': photoUrl ?? 'https://via.placeholder.com/150',
    };
  }

  factory LostItem.fromJson(Map<String, dynamic> json) {
    return LostItem(
      description: json['description']?.toString() ?? '',
      dateLost: DateTime.parse(json['dateLost']?.toString() ?? DateTime.now().toIso8601String()),
      busNumber: json['busNumber']?.toString() ?? '',
      contactName: json['contactName']?.toString() ?? '',
      contactPhone: json['contactPhone']?.toString() ?? '',
      photoUrl: json['photoUrl']?.toString(),
    );
  }
} 