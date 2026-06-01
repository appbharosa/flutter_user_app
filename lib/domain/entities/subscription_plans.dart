import 'dart:convert';

class SubscriptionPlans {
  final int id;
  final String name;
  final int price;
  final int discountPrice;
  final String duration;
  final int status;
  final int deleteStatus;
  final String createdOn;
  final String modifiedOn;
  final bool isExpired;
  final List<String> benefits;

  SubscriptionPlans({
    required this.id,
    required this.name,
    required this.price,
    required this.discountPrice,
    required this.duration,
    required this.status,
    required this.deleteStatus,
    required this.createdOn,
    required this.modifiedOn,
    required this.isExpired,
    required this.benefits,
  });

  factory SubscriptionPlans.fromJson(Map<String, dynamic> json) {
    final benefitsString = json['benefits'] ?? '[]';
    List<String> benefitsList = [];
    try {
      final decoded = jsonDecode(benefitsString);
      if (decoded is List) {
        benefitsList = decoded.map((e) => e.toString()).toList();
      }
    } catch (e) {
      benefitsList = [];
    }
    return SubscriptionPlans(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: json['price'] ?? 0,
      discountPrice: json['discount_price'] ?? 0,
      duration: json['duration'] ?? '',
      status: json['status'] ?? 0,
      deleteStatus: json['delete_status'] ?? 0,
      createdOn: json['created_on'] ?? '',
      modifiedOn: json['modified_on'] ?? '',
      isExpired: json['is_expired'] ?? false,
      benefits: benefitsList,
    );
  }
}