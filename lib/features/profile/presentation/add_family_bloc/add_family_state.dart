

import 'package:equatable/equatable.dart';

abstract class AddFamilyState extends Equatable {
  const AddFamilyState();
  @override
  List<Object?> get props => [];
}

class AddFamilyInitial extends AddFamilyState {}
class AddFamilyLoading extends AddFamilyState {}
class AddFamilySuccess extends AddFamilyState {
  final String message;
  const AddFamilySuccess(this.message);
  @override
  List<Object?> get props => [message];
}
class AddFamilyError extends AddFamilyState {
  final String message;
  const AddFamilyError(this.message);
  @override
  List<Object?> get props => [message];
}