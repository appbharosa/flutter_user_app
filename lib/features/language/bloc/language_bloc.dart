import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/utils/translations.dart';
import 'language_event.dart';
import 'language_state.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';



class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  static Language? _currentLanguage;
  static Language get currentLanguage => _currentLanguage ?? Language.english;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  LanguageBloc() : super(LanguageInitial()) {
    on<LoadSavedLanguage>(_onLoadSavedLanguage);
    on<ChangeLanguage>(_onChangeLanguage);
    add(LoadSavedLanguage());
  }

  Future<void> _onLoadSavedLanguage(LoadSavedLanguage event, Emitter<LanguageState> emit) async {
    final saved = await _storage.read(key: 'app_language');
    if (saved != null) {
      final lang = Language.values.firstWhere(
            (e) => e.toString() == saved,
        orElse: () => Language.english,
      );
      _currentLanguage = lang;
      AppTranslations.setLanguage(lang);
      emit(LanguageChanged(lang));
    } else {
      // Default to English if nothing saved
      _currentLanguage = Language.english;
      AppTranslations.setLanguage(Language.english);
      emit(LanguageChanged(Language.english)); // Ensures a consistent state
    }
  }

  void _onChangeLanguage(ChangeLanguage event, Emitter<LanguageState> emit) {
    _currentLanguage = event.language;
    AppTranslations.setLanguage(event.language);
    _storage.write(key: 'app_language', value: event.language.toString());
    emit(LanguageChanged(event.language));
  }
}