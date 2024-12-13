import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabebi/helper/generalMethods.dart';
import '../helper/sessionManager.dart';

class AppLocalizationState {
  final Locale language;
  AppLocalizationState(this.language);
}

class AppLocalizationCubit extends Cubit<AppLocalizationState> {
  SessionManager sessionManager;
  AppLocalizationCubit(this.sessionManager)
      : super(AppLocalizationState(GeneralMethods.getLocaleFromLanguageCode(
            sessionManager.getCurrLangCode())));

  void changeLanguage(String languageCode) {
    sessionManager.setData(SessionManager.keyLangCode, languageCode);
    emit(AppLocalizationState(
        GeneralMethods.getLocaleFromLanguageCode(languageCode)));
  }
}
