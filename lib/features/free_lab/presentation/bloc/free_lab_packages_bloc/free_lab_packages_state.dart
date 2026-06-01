import 'package:equatable/equatable.dart';
import '../../../../../domain/entities/free_lab_package.dart';

abstract class FreeLabPackagesState extends Equatable {
  const FreeLabPackagesState();
  @override
  List<Object?> get props => [];
}

class FreeLabPackagesInitial extends FreeLabPackagesState {}

class FreeLabPackagesLoading extends FreeLabPackagesState {}

class FreeLabPackagesLoaded extends FreeLabPackagesState {
  final List<FreeLabPackage> packages;
  const FreeLabPackagesLoaded(this.packages);
  @override
  List<Object?> get props => [packages];
}

class FreeLabPackagesError extends FreeLabPackagesState {
  final String message;
  const FreeLabPackagesError(this.message);
  @override
  List<Object?> get props => [message];
}