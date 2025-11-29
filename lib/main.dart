import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/database_helper.dart';
import 'blocs/word_bloc.dart';
import 'blocs/bookmark_bloc.dart';
import 'blocs/history_bloc.dart';
import 'blocs/theme_bloc.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/settings_screen.dart';

// TTS
import 'blocs/tts_bloc.dart';
import 'services/tts_services.dart';

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
        RepositoryProvider(
          create: (context) => TtsService(),
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
          BlocProvider(
            create: (context) => TtsBloc(context.read<TtsService>()),
          ),
        ],
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, state) {
            if (state is! ThemeLoaded) {
              return const SizedBox();
            }

            final themeData = state.themeData;

            final themeMode = state.themeMode == 'light'
                ? ThemeMode.light
                : state.themeMode == 'dark'
                    ? ThemeMode.dark
                    : ThemeMode.system;

            return MaterialApp(
              title: 'Tulish',
              debugShowCheckedModeBanner: false,
              theme: themeData,
              darkTheme: themeData,
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
