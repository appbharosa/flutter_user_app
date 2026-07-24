import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../domain/entities/address.dart';
import '../../../../domain/use_cases/add_address_usecase.dart';
import '../../../../domain/use_cases/get_addresses_usecase.dart';
import 'address_event.dart';
import 'address_state.dart';




class AddressBloc extends Bloc<AddressEvent, AddressState> {
  final GetAddressesUseCase getAddresses;
  final AddAddressUseCase addAddress;

  AddressBloc({
    required this.getAddresses,
    required this.addAddress,
  }) : super(AddressInitial()) {
    on<LoadAddresses>(_onLoadAddresses);
    on<AddNewAddress>(_onAddNewAddress);
  }

  // ✅ Helper that ensures only one address is marked as default
  List<Address> _fixDefaultAddresses(List<Address> addresses) {
    final defaultAddresses = addresses.where((a) => a.isDefault).toList();
    if (defaultAddresses.length <= 1) return addresses; // already correct

    bool firstFound = false;
    return addresses.map((addr) {
      if (addr.isDefault) {
        if (!firstFound) {
          firstFound = true;
          return addr; // keep the first default
        } else {
          // Set subsequent default addresses to false
          return addr.copyWith(isDefault: false);
        }
      }
      return addr;
    }).toList();
  }

  Future<void> _onLoadAddresses(LoadAddresses event, Emitter<AddressState> emit) async {
    emit(AddressLoading());
    final result = await getAddresses(lang: event.lang);
    result.fold(
          (failure) => emit(AddressError(failure.message)),
          (addresses) {
        // ✅ Apply the fix before emitting
        final fixedAddresses = _fixDefaultAddresses(addresses);
        emit(AddressLoaded(fixedAddresses));
      },
    );
  }

  Future<void> _onAddNewAddress(AddNewAddress event, Emitter<AddressState> emit) async {
    emit(AddressLoading());
    final result = await addAddress(
      AddAddressParams(event.addressData),
      lang: event.lang,
    );
    result.fold(
          (failure) => emit(AddressError(failure.message)),
          (_) {
        // Reload with the same language – the fix will be applied automatically
        add(LoadAddresses(event.lang));
        emit(AddressOperationSuccess('Address added successfully'));
      },
    );
  }
}