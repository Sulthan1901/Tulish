import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/database_helper.dart';
import 'blocs/word_bloc.dart';
import 'blocs/bookmark_bloc.dart';
import 'blocs/history_bloc.dart';
import 'blocs/theme_bloc.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const TulishApp());
}

class TulishApp extends StatelessWidget {
  const TulishApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => DatabaseHelper.instance,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => WordBloc(context.read<DatabaseHelper>()),
          ),
          BlocProvider(
            create: (context) => BookmarkBloc(context.read<DatabaseHelper>()),
          ),
          BlocProvider(
            create: (context) => HistoryBloc(context.read<DatabaseHelper>()),
          ),
          BlocProvider(
            create: (context) => ThemeBloc()..add(LoadThemeEvent()),
          ),
        ],
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, state) {
            ThemeMode themeMode = ThemeMode.dark;
            
            if (state is ThemeLoaded) {
              if (state.themeMode == 'light') {
                themeMode = ThemeMode.light;
              } else if (state.themeMode == 'dark') {
                themeMode = ThemeMode.dark;
              } else {
                themeMode = ThemeMode.system;
              }
            }

            return MaterialApp(
              title: 'Tulish',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              initialRoute: '/',
              routes: {
                '/': (context) => const SplashScreen(),
                '/home': (context) => const HomeScreen(),
                '/favorites': (context) => const FavoritesScreen(),
                '/settings': (context) => const SettingsScreen(),
              },
            );
          },
        ),
      ),
    );
  }
}
