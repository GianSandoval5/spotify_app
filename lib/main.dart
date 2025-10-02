// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:spotify_app/presentation/screens/login_screen.dart';
import 'package:spotify_app/presentation/screens/enhanced_login_screen.dart';
import 'package:spotify_app/presentation/screens/splash_screen.dart';
import 'injection_container.dart' as di;
import 'presentation/bloc/music/music_bloc.dart';
import 'presentation/bloc/favorites/favorites_bloc.dart';
import 'presentation/providers/audio_provider.dart';
import 'presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Hive
  await Hive.initFlutter();

  // Initialize dependencies
  await di.init();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF121212),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => di.sl<AudioProvider>()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => di.sl<MusicBloc>()),
          BlocProvider(create: (_) => di.sl<FavoritesBloc>()),
        ],
        child: MaterialApp(
          title: 'Spotify Clone',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212),
            primaryColor: const Color(0xFF1DB954),
            colorScheme: ColorScheme.dark(
              primary: const Color(0xFF1DB954),
              secondary: const Color(0xFF1DB954),
              surface: const Color(0xFF282828),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF121212),
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.white),
            ),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            useMaterial3: true,
          ),
          initialRoute: '/splash',
          routes: {
            '/splash': (context) => const SplashScreen(),
            '/login': (context) => const EnhancedLoginScreen(),
            '/login_simple': (context) => const LoginScreen(),
            '/home': (context) => const HomeScreen(),
          },
        ),
      ),
    );
  }
}
