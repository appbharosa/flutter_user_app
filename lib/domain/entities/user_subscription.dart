import 'dart:convert';

class UserSubscription {
  final int id;
  final String name;
  final int price;
  final int discountPrice;
  final String duration;
  final String fromDate;
  final String toDate;
  final int totalPremium;
  final String? invoice;
  final String status;
  final int deleteStatus;
  final String createdOn;
  final String modifiedOn;
  final List<String> benefits;
  final bool isExpired;

  // ✅ NEW FIELDS
  final String totalAmount;        // "5898.82"
  final String gst;                // "899.82"
  final CompanyDetails? companyDetails; // nested object

  UserSubscription({
    required this.id,
    required this.name,
    required this.price,
    required this.discountPrice,
    required this.duration,
    required this.fromDate,
    required this.toDate,
    required this.totalPremium,
    this.invoice,
    required this.status,
    required this.deleteStatus,
    required this.createdOn,
    required this.modifiedOn,
    required this.benefits,
    required this.isExpired,
    required this.totalAmount,
    required this.gst,
    this.companyDetails,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    // Parse benefits (supports both List and JSON string)
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

    // Parse company details
    CompanyDetails? companyDetails;
    final companyData = json['company_details'];
    if (companyData is Map<String, dynamic>) {
      companyDetails = CompanyDetails.fromJson(companyData);
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
      totalAmount: json['total_amount']?.toString() ?? '0',
      gst: json['gst']?.toString() ?? '0',
      companyDetails: companyDetails,
    );
  }
}
class CompanyDetails {
  final String address;
  final String addressPlain;
  final String gstNo;
  final String companyName;
  final String contactEmail;
  final String contactPhone;

  CompanyDetails({
    required this.address,
    required this.addressPlain,
    required this.gstNo,
    required this.companyName,
    required this.contactEmail,
    required this.contactPhone,
  });

  factory CompanyDetails.fromJson(Map<String, dynamic> json) {
    return CompanyDetails(
      address: json['address']?.toString() ?? '',
      addressPlain: json['address_plain']?.toString() ?? '',
      gstNo: json['gst_no']?.toString() ?? '',
      companyName: json['company_name']?.toString() ?? '',
      contactEmail: json['contact_email']?.toString() ?? '',
      contactPhone: json['contact_phone']?.toString() ?? '',
    );
  }
}