
import 'package:equatable/equatable.dart';

import '../../../../domain/entities/about.dart';

abstract class AboutState extends Equatable {
  const AboutState();
  @override
  List<Object> get props => [];
}

class AboutInitial extends AboutState {}
class AboutLoading extends AboutState {}
class AboutLoaded extends AboutState {
  final About about;
  const AboutLoaded(this.about);
  @override
  List<Object> get props => [about];
}
class AboutError extends AboutState {
  final String message;
  const AboutError(this.message);
  @override
  List<Object> get props => [message];
}