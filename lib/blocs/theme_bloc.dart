import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../utils/theme_prefs.dart';


// EVENTS
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


// STATES
abstract class ThemeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ThemeInitial extends ThemeState {}

class ThemeLoaded extends ThemeState {
  final ThemeData themeData;   // 🔥 WAJIB ADA
  final String themeMode;
  final double fontSize;

  ThemeLoaded({
    required this.themeData,
    required this.themeMode,
    required this.fontSize,
  });

  @override
  List<Object?> get props => [themeData, themeMode, fontSize];
}


/// BLOC
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeInitial()) {
    on<LoadThemeEvent>(_onLoadTheme);
    on<ChangeThemeEvent>(_onChangeTheme);
    on<ChangeFontSizeEvent>(_onChangeFontSize);
  }

  ThemeData _buildTheme(double fontSize, bool isDark) {
    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      fontFamily: "PlusJakartaSans",
      textTheme: TextTheme(
        bodyLarge: TextStyle(fontSize: fontSize + 2,fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(fontSize: fontSize,fontWeight: FontWeight.w600),
        bodySmall: TextStyle(fontSize: fontSize - 2,fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontSize: fontSize + 6,fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: fontSize + 4,fontWeight: FontWeight.w600),
        titleSmall: TextStyle(fontSize: fontSize + 2,fontWeight: FontWeight.w600),
      ),
      useMaterial3: true,
    );
  }

  Future<void> _onLoadTheme(LoadThemeEvent event, Emitter<ThemeState> emit) async {
    final themeMode = await ThemePrefs.getThemeMode();
    final fontSize = await ThemePrefs.getFontSize();

    final isDark = themeMode == 'dark';

    emit(
      ThemeLoaded(
        themeData: _buildTheme(fontSize, isDark),
        themeMode: themeMode,
        fontSize: fontSize,
      ),
    );
  }

  Future<void> _onChangeTheme(ChangeThemeEvent event, Emitter<ThemeState> emit) async {
    await ThemePrefs.setThemeMode(event.themeMode);
    final fontSize = await ThemePrefs.getFontSize();

    final isDark = event.themeMode == 'dark';

    emit(
      ThemeLoaded(
        themeData: _buildTheme(fontSize, isDark),
        themeMode: event.themeMode,
        fontSize: fontSize,
      ),
    );
  }

  Future<void> _onChangeFontSize(ChangeFontSizeEvent event, Emitter<ThemeState> emit) async {
    await ThemePrefs.setFontSize(event.fontSize);
    final themeMode = await ThemePrefs.getThemeMode();
    final isDark = themeMode == 'dark';

    emit(
      ThemeLoaded(
        themeData: _buildTheme(event.fontSize, isDark),
        themeMode: themeMode,
        fontSize: event.fontSize,
      ),
    );
  }
}
