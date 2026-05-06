import '../../domain/entities/subscription_plan.dart';


class SubscriptionPlanModel extends SubscriptionPlan {
  const SubscriptionPlanModel({
    required super.id,
    required super.name,
    required super.price,
    required super.discountPrice,
    required super.duration,
    required super.benefits,
    required super.finalPrice,
    required super.baseAmount,
    required super.gstAmount,
    required super.totalAmount,
    required super.savings,
    required super.personsCovered,
    required super.coverageType,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    final priceDetails = json['price_details'] as Map<String, dynamic>;
    final coverageDetails = json['coverage_details'] as Map<String, dynamic>;

    return SubscriptionPlanModel(
      id: json['id'],
      name: json['name'],
      price: parseDouble(json['price']),
      discountPrice: parseDouble(json['discount_price']),
      duration: json['duration'],
      benefits: List<String>.from(json['benefits']),
      finalPrice: parseDouble(priceDetails['final_price']),
      baseAmount: parseDouble(priceDetails['base_amount']),
      gstAmount: parseDouble(priceDetails['gst_amount']),
      totalAmount: parseDouble(priceDetails['total_amount']),
      savings: parseDouble(priceDetails['savings']),
      personsCovered: coverageDetails['persons_covered'],
      coverageType: coverageDetails['coverage_type'],
    );
  }
}