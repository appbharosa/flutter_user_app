
import 'package:equatable/equatable.dart';

import '../../../../domain/entities/pharmacy.dart';

abstract class PharmacyState extends Equatable {
  const PharmacyState();
  @override List<Object> get props => [];
}

class PharmacyInitial extends PharmacyState {}
class PharmacyLoading extends PharmacyState {}
class PharmacyLoaded extends PharmacyState {
  final List<Pharmacy> pharmacies;
  final bool hasMore;
  const PharmacyLoaded(this.pharmacies, this.hasMore);
  @override List<Object> get props => [pharmacies, hasMore];
}
class PharmacyError extends PharmacyState {
  final String message;
  const PharmacyError(this.message);
  @override List<Object> get props => [message];
}