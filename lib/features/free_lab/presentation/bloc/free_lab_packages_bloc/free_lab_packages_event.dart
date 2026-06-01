import 'package:equatable/equatable.dart';

abstract class FreeLabPackagesEvent extends Equatable {
  const FreeLabPackagesEvent();
  @override
  List<Object?> get props => [];
}

class LoadFreeLabPackages extends FreeLabPackagesEvent {
  final String language;
  const LoadFreeLabPackages(this.language);
  @override
  List<Object?> get props => [language];
}