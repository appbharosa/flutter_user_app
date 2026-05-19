
import 'package:equatable/equatable.dart';

abstract class ECardEvent extends Equatable {
  const ECardEvent();
  @override
  List<Object?> get props => [];
}

class LoadECard extends ECardEvent {
  final String language;
  const LoadECard(this.language);
  @override
  List<Object?> get props => [language];
}