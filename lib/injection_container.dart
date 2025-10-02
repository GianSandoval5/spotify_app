import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:spotify_app/data/models/users_models.dart';
import 'package:spotify_app/data/repositories/user_repository_impl.dart';
import 'package:spotify_app/data/services/audio_service.dart';
import 'package:spotify_app/data/services/auth_service.dart';
import 'package:spotify_app/data/services/spotify_service.dart' as sdk;
import 'package:spotify_app/data/services/spotify_web_service.dart' as web;
import 'package:spotify_app/domain/repositories/user_repository.dart';
import 'data/datasources/local_data_source.dart';
import 'data/datasources/remote_data_source.dart';
import 'data/repositories/music_repository_impl.dart';
import 'domain/repositories/music_repository.dart';
import 'presentation/bloc/music/music_bloc.dart';
import 'presentation/bloc/favorites/favorites_bloc.dart';
import 'presentation/providers/audio_provider.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // BLoC
  sl.registerFactory(() => MusicBloc(sl()));
  sl.registerFactory(() => FavoritesBloc(sl()));

  // Providers
  sl.registerLazySingleton(() => AudioProvider());

  // Registrar UserModel para Hive
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(UserModelAdapter());
  }

  // Services (orden importante para evitar dependencias circulares)
  sl.registerLazySingleton(() => AudioPlayerService());
  sl.registerLazySingleton(() => sdk.SpotifyService.instance);
  sl.registerLazySingleton(() => web.SpotifyService.instance);

  // Repository
  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl());

  sl.registerLazySingleton<AuthService>(
    () => AuthService(
      userRepository: sl<UserRepository>(),
      spotifyWebService: sl<web.SpotifyService>(),
      spotifySDKService: sl<sdk.SpotifyService>(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton(() => LocalDataSource());
  sl.registerLazySingleton<RemoteDataSource>(
    () => RemoteDataSource(authService: sl<AuthService>()),
  );

  // Repository que depende de DataSources
  sl.registerLazySingleton<MusicRepository>(
    () => MusicRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  // Initialize services (orden importante)
  await sl<LocalDataSource>().init();
  await sl<AudioPlayerService>().init();

  // Inicializar repositorio de usuarios después de registrar todos los servicios
  final userRepository = sl<UserRepository>() as UserRepositoryImpl;
  await userRepository.init();
}
