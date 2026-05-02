import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

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

  Future<void> _onLoadAddresses(LoadAddresses event, Emitter<AddressState> emit) async {
    emit(AddressLoading());
    final result = await getAddresses();
    result.fold(
          (failure) => emit(AddressError(failure.message)),
          (addresses) => emit(AddressLoaded(addresses)),
    );
  }

  Future<void> _onAddNewAddress(AddNewAddress event, Emitter<AddressState> emit) async {
    emit(AddressLoading());
    final result = await addAddress(AddAddressParams(event.addressData));
    result.fold(
          (failure) => emit(AddressError(failure.message)),
          (_) {
        // After adding, reload the list
        add(LoadAddresses());
        emit(AddressOperationSuccess('Address added successfully'));
      },
    );
  }
}