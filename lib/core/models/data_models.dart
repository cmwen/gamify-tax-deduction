// Data models for the Gamified Tax Deduction app
// Following the design document specifications

class Receipt {
  final String id; // UUID
  final DateTime createdAt;
  final String imagePath; // Path to the image file in local app storage
  final String? vendorName;
  final double totalAmount;
  final double potentialTaxSaving;
  final String? category; // For Post-MVP
  
  const Receipt({
    required this.id,
    required this.createdAt,
    required this.imagePath,
    this.vendorName,
    required this.totalAmount,
    required this.potentialTaxSaving,
    this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'imagePath': imagePath,
      'vendorName': vendorName,
      'totalAmount': totalAmount,
      'potentialTaxSaving': potentialTaxSaving,
      'category': category,
    };
  }

  factory Receipt.fromMap(Map<String, dynamic> map) {
    return Receipt(
      id: map['id'],
      createdAt: DateTime.parse(map['createdAt']),
      imagePath: map['imagePath'],
      vendorName: map['vendorName'],
      totalAmount: map['totalAmount'],
      potentialTaxSaving: map['potentialTaxSaving'],
      category: map['category'],
    );
  }
}