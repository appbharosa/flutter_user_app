import 'package:dartz/dartz.dart' hide Order;
import '../../core/errors/failures.dart';
import '../entities/order.dart';


abstract class OrderRepository {
  Future<Either<Failure,Order>> createOrder({
    required int pharmacyId,
    required String orderType,
    required List<String> prescriptionPaths,
    required String lang,
    required int addressId,
  });
}