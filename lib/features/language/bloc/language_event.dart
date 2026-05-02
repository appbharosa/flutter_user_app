
import 'package:equatable/equatable.dart';

import '../../../core/utils/translations.dart';


abstract class LanguageEvent extends Equatable {
  const LanguageEvent();
  @override List<Object> get props => [];
}

class LoadSavedLanguage extends LanguageEvent {}
class ChangeLanguage extends LanguageEvent {
  final Language language;
  const ChangeLanguage(this.language);
  @override List<Object> get props => [language];
}