part of 'app_cubit.dart';

abstract class AppState extends Equatable {
  final Locale locale;

  const AppState(this.locale);

  @override
  List<Object?> get props => [locale];
}

class AppInitial extends AppState {
  const AppInitial(super.locale);
}

class AppLanguageChanged extends AppState {
  const AppLanguageChanged(super.locale);
}

