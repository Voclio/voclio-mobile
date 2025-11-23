part of 'app_cubit.dart';

abstract class AppState extends Equatable {
  final Locale locale;

  const AppState(this.locale);

  @override
  List<Object?> get props => [locale];
}

class AppInitial extends AppState {
  const AppInitial(Locale locale) : super(locale);
}

class AppLanguageChanged extends AppState {
  const AppLanguageChanged(Locale locale) : super(locale);
}

