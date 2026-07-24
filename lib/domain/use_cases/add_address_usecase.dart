import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/address.dart';
import '../repositories/address_repository.dart';

class AddAddressParams {
  final Map<String, dynamic> addressData;
  AddAddressParams(this.addressData);
}

class AddAddressUseCase {
  final AddressRepository repository;
  AddAddressUseCase(this.repository);

  // Add lang as a required parameter
  Future<Either<Failure, Address>> call(AddAddressParams params, {required String lang}) async {
    return await repository.addAddress(params.addressData, lang: lang);
  }
}