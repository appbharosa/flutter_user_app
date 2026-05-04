

import 'package:equatable/equatable.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();
  @override List<Object> get props => [];
}

class CreateOrderEvent extends OrderEvent {
  final int pharmacyId;
  final String orderType;
  final List<String> prescriptionPaths;
  final String lang;
  final int addressId;

  const CreateOrderEvent({
    required this.pharmacyId,
    required this.orderType,
    required this.prescriptionPaths,
    required this.lang,
    required this.addressId,
  });
}