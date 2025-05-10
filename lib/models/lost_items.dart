class LostItem {
  final String busNumber;
  final String description;
  final DateTime dateLost;
  final String reporterName;
  final String reporterPhone;
  final String? image;  

  LostItem({
    required this.busNumber,
    required this.description,
    required this.dateLost,
    required this.reporterName,
    required this.reporterPhone,
    this.image, required String photoUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'busNumber': busNumber,
      'description': description,
      'dateLost': dateLost.toIso8601String(),
      'reporterName': reporterName,
      'reporterPhone': reporterPhone,
      'image': image,
    };
  }

  factory LostItem.fromJson(Map<String, dynamic> json) {
    return LostItem(
      busNumber: json['busNumber'],
      description: json['description'],
      dateLost: DateTime.parse(json['dateLost']),
      reporterName: json['reporterName'],
      reporterPhone: json['reporterPhone'],
      image: json['image'], photoUrl: '',
    );
  }

  String get photoUrl {
    if (image == null || image!.isEmpty) {
      return 'https://via.placeholder.com/150'; 
    } else if (image!.startsWith('http')) {
      return image!; 
    } else {
      return 'data:image/jpeg;base64,$image'; 
    }
  }
}
