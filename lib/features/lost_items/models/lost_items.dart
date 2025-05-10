class LostItem {
  final String description;
  final DateTime dateLost;
  final String busNumber;
  final String? image;
  final String photoUrl;

  LostItem({
    required this.description,
    required this.dateLost,
    required this.busNumber,
    this.image,
    required this.photoUrl,
  });

  factory LostItem.fromJson(Map<String, dynamic> json) {
    return LostItem(
      description: json['description'] ?? '',
      dateLost: DateTime.parse(json['dateLost']),
      busNumber: json['busNumber'] ?? '',
      image: json['image'],
      photoUrl: json['photoUrl'] ?? '',
    );
  }
} 