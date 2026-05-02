import 'package:equatable/equatable.dart';
import '../../../core/utils/translations.dart';


abstract class LanguageState extends Equatable {
  const LanguageState();
  @override List<Object> get props => [];
}

class LanguageInitial extends LanguageState {}
class LanguageChanged extends LanguageState {
  final Language language;
  const LanguageChanged(this.language);
  @override List<Object> get props => [language];
}