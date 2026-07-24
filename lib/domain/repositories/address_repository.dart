import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/address.dart';


abstract class AddressRepository {
  Future<Either<Failure, List<Address>>> getAddresses({required String lang});
  Future<Either<Failure, Address>> addAddress(Map<String, dynamic> addressData, {required String lang});
}