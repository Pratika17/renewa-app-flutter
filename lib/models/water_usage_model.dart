class WaterUsage {
  final String billNo;
  final String previousUsage;
  final String currentUsage;
  final String description;
  final String previousImageUrl;
  final String currentImageUrl;
  final String numEmployees;

  WaterUsage({
    required this.billNo,
    required this.previousUsage,
    required this.currentUsage,
    required this.description,
    required this.previousImageUrl,
    required this.currentImageUrl,
    required this.numEmployees,
  });

  WaterUsage copyWith({
    String? billNo,
    String? previousUsage,
    String? currentUsage,
    String? description,
    String? previousImageUrl,
    String? currentImageUrl,
    String? numEmployees,
  }) {
    return WaterUsage(
      billNo: billNo ?? this.billNo,
      previousUsage: previousUsage ?? this.previousUsage,
      currentUsage: currentUsage ?? this.currentUsage,
      description: description ?? this.description,
      previousImageUrl: previousImageUrl ?? this.previousImageUrl,
      currentImageUrl: currentImageUrl ?? this.currentImageUrl,
      numEmployees: numEmployees ?? this.numEmployees,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'billNo': billNo,
      'previousUsage': previousUsage,
      'currentUsage': currentUsage,
      'description': description,
      'previousImageUrl': previousImageUrl,
      'currentImageUrl': currentImageUrl,
      'numEmployees': numEmployees,
    };
  }

  factory WaterUsage.fromMap(Map<String, dynamic> map) {
    return WaterUsage(
      billNo: map['billNo'],
      previousUsage: map['previousUsage'],
      currentUsage: map['currentUsage'],
      description: map['description'],
      previousImageUrl: map['previousImageUrl'],
      currentImageUrl: map['currentImageUrl'],
      numEmployees: map['numEmployees'],
    );
  }
}
