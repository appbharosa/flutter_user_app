
import 'package:equatable/equatable.dart';


abstract class AddressEvent extends Equatable {
  const AddressEvent();
  @override
  List<Object> get props => [];
}

class LoadAddresses extends AddressEvent {
  final String lang;
  const LoadAddresses(this.lang);
  @override
  List<Object> get props => [lang];
}

class AddNewAddress extends AddressEvent {
  final Map<String, dynamic> addressData;
  final String lang;
  const AddNewAddress(this.addressData, this.lang);
  @override
  List<Object> get props => [addressData, lang];
}