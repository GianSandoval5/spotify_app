# 📁 Estructura Completa del Proyecto - Spotify Clone

## 🌳 Árbol de Directorios

```
spotify_clone/
│
├── android/                          # Configuración Android
│   ├── app/
│   │   └── src/
│   │       └── main/
│   │           └── AndroidManifest.xml    # ⚠️ IMPORTANTE: Permisos y servicios
│   └── build.gradle
│
├── ios/                              # Configuración iOS
│   └── Runner/
│       └── Info.plist
│
├── lib/                              # 🎯 CÓDIGO PRINCIPAL
│   │
│   ├── main.dart                     # ✅ Punto de entrada de la app
│   ├── injection_container.dart      # ✅ Dependency Injection (GetIt)
│   │
│   ├── domain/                       # 🏛️ CAPA DE DOMINIO
│   │   ├── entities/                 # Entidades del negocio
│   │   │   ├── song.dart            # ✅ Entidad Song
│   │   │   ├── artist.dart          # ✅ Entidad Artist
│   │   │   └── playlist.dart        # ✅ Entidad Playlist
│   │   │
│   │   └── repositories/            # Interfaces (contratos)
│   │       └── music_repository.dart # ✅ Contrato del repositorio
│   │
│   ├── data/                         # 💾 CAPA DE DATOS
│   │   ├── models/                   # Modelos de datos (Hive)
│   │   │   ├── song_model.dart      # ✅ Modelo + Hive annotations
│   │   │   └── song_model.g.dart    # 🔄 Auto-generado (build_runner)
│   │   │
│   │   ├── datasources/             # Fuentes de datos
│   │   │   ├── local_data_source.dart    # ✅ Hive operations
│   │   │   └── remote_data_source.dart   # ✅ API calls (Mock)
│   │   │
│   │   ├── repositories/            # Implementación de repositorios
│   │   │   └── music_repository_impl.dart # ✅ Implementación
│   │   │
│   │   └── services/                # Servicios
│   │       └── audio_player_service.dart  # ✅ JustAudio + Background
│   │
│   └── presentation/                 # 🎨 CAPA DE PRESENTACIÓN
│       │
│       ├── bloc/                     # State Management (BLoC)
│       │   ├── music/               # BLoC de música
│       │   │   ├── music_bloc.dart  # ✅ BLoC principal
│       │   │   ├── music_event.dart # ✅ Eventos
│       │   │   └── music_state.dart # ✅ Estados
│       │   │
│       │   └── favorites/           # BLoC de favoritos
│       │       ├── favorites_bloc.dart  # ✅ BLoC favoritos
│       │       └── (eventos y estados en mismo archivo)
│       │
│       ├── providers/               # State Management (Provider)
│       │   └── audio_provider.dart  # ✅ Provider del audio player
│       │
│       ├── screens/                 # Pantallas
│       │   ├── home_screen.dart     # ✅ Pantalla principal
│       │   ├── search_screen.dart   # ✅ Buscador
│       │   ├── library_screen.dart  # ✅ Biblioteca/Favoritos
│       │   └── player_screen.dart   # ✅ Reproductor expandido
│       │
│       └── widgets/                 # Widgets reutilizables
│           └── mini_player.dart     # ✅ Mini reproductor
│
├── assets/                           # Recursos estáticos
│   ├── images/                      # Imágenes
│   └── icons/                       # Iconos
│
├── test/                            # Tests unitarios
│   └── widget_test.dart
│
├── pubspec.yaml                      # ✅ Dependencias del proyecto
├── build.yaml                        # ✅ Configuración build_runner
├── README.md                         # ✅ Documentación principal
├── COMANDOS.md                       # ✅ Comandos útiles
└── ESTRUCTURA_PROYECTO.md           # ✅ Este archivo

```

## 📋 Checklist de Archivos Creados

### ✅ Configuración Base
- [x] `pubspec.yaml` - Dependencias
- [x] `build.yaml` - Configuración build_runner
- [x] `android/app/src/main/AndroidManifest.xml` - Permisos Android
- [x] `lib/main.dart` - Punto de entrada

### ✅ Domain Layer (Dominio)
- [x] `lib/domain/entities/song.dart`
- [x] `lib/domain/entities/artist.dart`
- [x] `lib/domain/entities/playlist.dart`
- [x] `lib/domain/repositories/music_repository.dart`

### ✅ Data Layer (Datos)
- [x] `lib/data/models/song_model.dart` (+ Hive annotations)
- [x] `lib/data/datasources/local_data_source.dart` (Hive)
- [x] `lib/data/datasources/remote_data_source.dart` (API Mock)
- [x] `lib/data/repositories/music_repository_impl.dart`
- [x] `lib/data/services/audio_player_service.dart`

### ✅ Presentation Layer (Presentación)
- [x] `lib/presentation/bloc/music/music_bloc.dart`
- [x] `lib/presentation/bloc/music/music_event.dart`
- [x] `lib/presentation/bloc/music/music_state.dart`
- [x] `lib/presentation/bloc/favorites/favorites_bloc.dart`
- [x] `lib/presentation/providers/audio_provider.dart`
- [x] `lib/presentation/screens/home_screen.dart`
- [x] `lib/presentation/screens/search_screen.dart`
- [x] `lib/presentation/screens/library_screen.dart`
- [x] `lib/presentation/screens/player_screen.dart`
- [x] `lib/presentation/widgets/mini_player.dart`

### ✅ Dependency Injection
- [x] `lib/injection_container.dart` (GetIt)

### ✅ Documentación
- [x] `README.md`
- [x] `COMANDOS.md`
- [x] `ESTRUCTURA_PROYECTO.md`

## 🎯 Flujo de Datos Completo

```
┌─────────────────────────────────────────────────────────────┐
│                         UI LAYER                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ HomeScreen   │  │ SearchScreen │  │ LibraryScreen│      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         │                  │                  │              │
│         └──────────────────┴──────────────────┘              │
│                            │                                 │
└────────────────────────────┼─────────────────────────────