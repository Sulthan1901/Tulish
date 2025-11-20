import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../utils/theme_prefs.dart';

// Events
abstract class ThemeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadThemeEvent extends ThemeEvent {}

class ChangeThemeEvent extends ThemeEvent {
  final String themeMode;
  ChangeThemeEvent(this.themeMode);
  @override
  List<Object?> get props => [themeMode];
}

class ChangeFontSizeEvent extends ThemeEvent {
  final double fontSize;
  ChangeFontSizeEvent(this.fontSize);
  @override
  List<Object?> get props => [fontSize];
}

// States
abstract class ThemeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ThemeInitial extends ThemeState {}

class ThemeLoaded extends ThemeState {
  final String themeMode;
  final double fontSize;
  
  ThemeLoaded({required this.themeMode, required this.fontSize});
  
  @override
  List<Object?> get props => [themeMode, fontSize];
}

// BLoC
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeInitial()) {
    on<LoadThemeEvent>(_onLoadTheme);
    on<ChangeThemeEvent>(_onChangeTheme);
    on<ChangeFontSizeEvent>(_onChangeFontSize);
  }

  Future<void> _onLoadTheme(LoadThemeEvent event, Emitter<ThemeState> emit) async {
    final themeMode = await ThemePrefs.getThemeMode();
    final fontSize = await ThemePrefs.getFontSize();
    emit(ThemeLoaded(themeMode: themeMode, fontSize: fontSize));
  }

  Future<void> _onChangeTheme(ChangeThemeEvent event, Emitter<ThemeState> emit) async {
    await ThemePrefs.setThemeMode(event.themeMode);
    final fontSize = await ThemePrefs.getFontSize();
    emit(ThemeLoaded(themeMode: event.themeMode, fontSize: fontSize));
  }

  Future<void> _onChangeFontSize(ChangeFontSizeEvent event, Emitter<ThemeState> emit) async {
    await ThemePrefs.setFontSize(event.fontSize);
    final themeMode = await ThemePrefs.getThemeMode();
    emit(ThemeLoaded(themeMode: themeMode, fontSize: event.fontSize));
  }
}
