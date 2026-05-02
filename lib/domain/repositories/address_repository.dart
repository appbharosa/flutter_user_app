import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/address.dart';


abstract class AddressRepository {
  Future<Either<Failure, List<Address>>> getAddresses();
  Future<Either<Failure, Address>> addAddress(Map<String, dynamic> addressData);
  // Future<Either<Failure, void>> setDefaultAddress(int addressId);
}