import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/utils/translations.dart';
import 'language_event.dart';
import 'language_state.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';



class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  LanguageBloc() : super(LanguageInitial()) {
    on<LoadSavedLanguage>(_onLoadSavedLanguage);
    on<ChangeLanguage>(_onChangeLanguage);
    add(LoadSavedLanguage()); // load on start
  }

  Future<void> _onLoadSavedLanguage(LoadSavedLanguage event, Emitter<LanguageState> emit) async {
    final saved = await _storage.read(key: 'app_language');
    if (saved != null) {
      final lang = Language.values.firstWhere(
            (e) => e.toString() == saved,
        orElse: () => Language.english,
      );
      AppTranslations.setLanguage(lang);
      emit(LanguageChanged(lang));
    } else {
      // No saved language – stay in initial state (user will choose)
    }
  }

  void _onChangeLanguage(ChangeLanguage event, Emitter<LanguageState> emit) {
    AppTranslations.setLanguage(event.language);
    _storage.write(key: 'app_language', value: event.language.toString());
    emit(LanguageChanged(event.language));
  }
}