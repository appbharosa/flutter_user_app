import 'package:equatable/equatable.dart';


class SubscriptionPlan extends Equatable {
  final int id;
  final String name;
  final double price;
  final double discountPrice;
  final String duration;
  final List<String> benefits;
  final double finalPrice;
  final double baseAmount;
  final double gstAmount;
  final double totalAmount;
  final double savings;
  final int personsCovered;
  final String coverageType;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.discountPrice,
    required this.duration,
    required this.benefits,
    required this.finalPrice,
    required this.baseAmount,
    required this.gstAmount,
    required this.totalAmount,
    required this.savings,
    required this.personsCovered,
    required this.coverageType,
  });

  @override
  List<Object?> get props => [id, name];
}