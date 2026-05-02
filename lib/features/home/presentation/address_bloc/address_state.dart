import 'package:equatable/equatable.dart';
import '../../../../domain/entities/address.dart';


abstract class AddressState extends Equatable {
  const AddressState();
  @override List<Object> get props => [];
}

class AddressInitial extends AddressState {}
class AddressLoading extends AddressState {}
class AddressLoaded extends AddressState {
  final List<Address> addresses;
  const AddressLoaded(this.addresses);
  @override List<Object> get props => [addresses];
}
class AddressOperationSuccess extends AddressState {
  final String message;
  const AddressOperationSuccess(this.message);
}
class AddressError extends AddressState {
  final String message;
  const AddressError(this.message);
}