import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/address.dart';
import '../repositories/address_repository.dart';


class GetAddressesUseCase {
  final AddressRepository repository;
  GetAddressesUseCase(this.repository);

  // Accept lang as a required parameter
  Future<Either<Failure, List<Address>>> call({required String lang}) async {
    return await repository.getAddresses(lang: lang);
  }
}