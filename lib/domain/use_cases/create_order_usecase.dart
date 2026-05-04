import 'package:dartz/dartz.dart' hide Order;
import '../../core/errors/failures.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';


class CreateOrderParams {
  final int pharmacyId;
  final String orderType;
  final List<String> prescriptionPaths;
  final String lang;
  final int addressId;

  CreateOrderParams({
    required this.pharmacyId,
    required this.orderType,
    required this.prescriptionPaths,
    required this.lang,
    required this.addressId,
  });
}

class CreateOrderUseCase {
  final OrderRepository repository;

  CreateOrderUseCase(this.repository);

  Future<Either<Failure, Order>> call(CreateOrderParams params) async {
    return await repository.createOrder(
      pharmacyId: params.pharmacyId,
      orderType: params.orderType,
      prescriptionPaths: params.prescriptionPaths,
      lang: params.lang,
      addressId: params.addressId,
    );
  }
}