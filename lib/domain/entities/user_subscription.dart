import 'dart:convert';

class UserSubscription {
  final int id;
  final String name;
  final int price;
  final int discountPrice;
  final String duration; // Keep as String since API returns "12 MONTHS"
  final String fromDate;
  final String toDate;
  final int totalPremium;
  final String? invoice; // Make nullable since it can be null in response
  final String status; // Changed to String since API returns "active"
  final int deleteStatus;
  final String createdOn;
  final String modifiedOn;
  final List<String> benefits;
  final bool isExpired;

  UserSubscription({
    required this.id,
    required this.name,
    required this.price,
    required this.discountPrice,
    required this.duration,
    required this.fromDate,
    required this.toDate,
    required this.totalPremium,
    required this.invoice,
    required this.status,
    required this.deleteStatus,
    required this.createdOn,
    required this.modifiedOn,
    required this.benefits,
    required this.isExpired,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    // Handle benefits which is already a List in your API response
    List<String> benefitsList = [];
    final benefitsData = json['benefits'];
    if (benefitsData is List) {
      benefitsList = benefitsData.map((e) => e.toString()).toList();
    } else if (benefitsData is String) {
      try {
        final decoded = jsonDecode(benefitsData);
        if (decoded is List) {
          benefitsList = decoded.map((e) => e.toString()).toList();
        }
      } catch (e) {
        benefitsList = [];
      }
    }

    return UserSubscription(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      price: json['price'] as int? ?? 0,
      discountPrice: json['discount_price'] as int? ?? 0,
      duration: json['duration'] as String? ?? '',
      fromDate: json['from_date'] as String? ?? '',
      toDate: json['to_date'] as String? ?? '',
      totalPremium: json['total_premium'] as int? ?? 0,
      invoice: json['invoice'] as String?,
      status: json['status'] as String? ?? '',
      deleteStatus: json['delete_status'] as int? ?? 0,
      createdOn: json['created_on'] as String? ?? '',
      modifiedOn: json['modified_on'] as String? ?? '',
      benefits: benefitsList,
      isExpired: json['is_expired'] as bool? ?? false,
    );
  }
}