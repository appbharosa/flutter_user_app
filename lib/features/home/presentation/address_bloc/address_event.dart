
import 'package:equatable/equatable.dart';


abstract class AddressEvent extends Equatable {
  const AddressEvent();
  @override List<Object> get props => [];
}

class LoadAddresses extends AddressEvent {}
class AddNewAddress extends AddressEvent {
  final Map<String, dynamic> addressData;
  const AddNewAddress(this.addressData);
}