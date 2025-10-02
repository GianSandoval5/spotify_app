# 🎵 Spotify Clone - Flutter

Un clon completamente funcional de Spotify construido con Flutter, Clean Architecture, BLoC, Provider y reproducción en segundo plano.

## ✨ Características

- ✅ **Reproductor de Audio Completo** - Reproducción en segundo plano con notificaciones
- 🎨 **UI Profesional** - Diseño inspirado en Spotify con animaciones fluidas
- 🔍 **Búsqueda en Tiempo Real** - Busca canciones, artistas y álbumes
- ❤️ **Sistema de Favoritos** - Guarda tus canciones favoritas localmente
- 📱 **Mini Player Animado** - Transiciones suaves entre mini y reproductor expandido
- 🎵 **Controles Multimedia** - Play, pause, siguiente, anterior, shuffle, repeat
- 💾 **Persistencia Local** - Hive para guardar favoritos y historial
- 🏗️ **Clean Architecture** - Separación clara de capas (Domain, Data, Presentation)
- 🎯 **State Management** - BLoC + Provider
- 🎨 **Extracción de Colores** - Paleta dinámica desde las carátulas
- 📊 **Slider de Progreso** - Barra de progreso interactiva
- 🔔 **Notificaciones** - Controles multimedia en la barra de notificaciones

## 🏛️ Arquitectura

```
lib/
├── domain/                 # Capa de Dominio
│   ├── entities/          # Entidades del negocio
│   └── repositories/      # Interfaces de repositorios
├── data/                  # Capa de Datos
│   ├── models/           # Modelos de datos (Hive)
│   ├── datasources/      # Fuentes de datos (Local/Remote)
│   ├── repositories/     # Implementación de repositorios
│   └── services/         # Servicios (AudioPlayerService)
├── presentation/          # Capa de Presentación
│   ├── bloc/            # BLoC (State Management)
│   ├── providers/       # Providers
│   ├── screens/         # Pantallas
│   └── widgets/         # Widgets reutilizables
└── injection_container.dart  # Dependency Injection (GetIt)
```

## 🚀 Instalación

### Prerequisitos

- Flutter 3.0 o superior
- Dart 3.0 o superior
- Android Studio / VS Code
- Dispositivo Android o iOS (o emulador)

### Pasos de Instalación

1. **Clonar el repositorio**
```bash
git clone <tu-repositorio>
cd spotify_clone
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Generar archivos Hive**
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

4. **Configurar permisos Android**

Asegúrate de que el archivo `android/app/src/main/AndroidManifest.xml` tenga los permisos necesarios (ya incluidos en el archivo proporcionado).

5. **Ejecutar la aplicación**
```bash
flutter run
```

## 📦 Dependencias Principales

```yaml
# State Management
flutter_bloc: ^8.1.3
provider: ^6.1.1

# Audio Player
just_audio: ^0.9.36
just_audio_background: ^0.0.1-beta.11
audio_service: ^0.18.12

# Local Storage
hive: ^2.2.3
hive_flutter: ^1.1.0

# HTTP & API
dio: ^5.4.0

# UI & Animations
cached_network_image: ^3.3.0
palette_generator: ^0.3.3+3
animations: ^2.0.11

# Dependency Injection
get_it: ^7.6.4
dartz: ^0.10.1
```

## 🎯 Características Técnicas

### Clean Architecture
- **Domain Layer**: Entidades y contratos de repositorios
- **Data Layer**: Implementación de repositorios, modelos y data sources
- **Presentation Layer**: BLoC, Providers, UI

### State Management
- **BLoC**: Para búsqueda, playlists y favoritos
- **Provider**: Para el estado del reproductor de audio

### Persistencia de Datos
- **Hive**: Base de datos NoSQL local para favoritos
- **Hive Flutter**: Adaptadores personalizados para entidades

### Audio Service
- Reproducción en segundo plano
- Notificaciones multimedia
- Controles en pantalla de bloqueo
- Soporte para audífonos Bluetooth

## 🎨 Características de UI

### Mini Player
- Muestra la canción actual
- Controles básicos (play/pause, next)
- Barra de progreso
- Transición suave al reproductor expandido

### Reproductor Expandido
- Carátula grande con animación
- Extracción de colores dominantes
- Slider de progreso interactivo
- Controles completos (shuffle, repeat, favoritos)
- Información detallada de la canción

### Búsqueda
- Búsqueda en tiempo real
- Categorías de música
- Resultados instantáneos
- UI similar a Spotify

### Biblioteca
- Tabs: Favoritos, Playlists, Artistas
- Swipe to delete en favoritos
- Botón "Play All"
- Lista ordenada de canciones

## 📱 Capturas de Pantalla

(Agrega aquí capturas de pantalla de tu aplicación)

## 🔄 Flujo de Datos

```
UI (Widgets) 
    ↓
Provider / BLoC
    ↓
Repository (Interface)
    ↓
Repository Implementation
    ↓
Data Sources (Local/Remote)
    ↓
APIs / Hive Database
```

## 🛠️ Próximas Características

- [ ] Integración con Spotify API real
- [ ] Autenticación de usuarios
- [ ] Crear y editar playlists
- [ ] Compartir canciones
- [ ] Modo offline
- [ ] Ecualizador
- [ ] Letras de canciones
- [ ] Recomendaciones personalizadas

## 📝 Notas Importantes

### API Mock
Actualmente usa datos mock. Para usar la API real de Spotify:
1. Crea una aplicación en [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Obtén tus credenciales (Client ID y Client Secret)
3. Implementa OAuth 2.0 en `RemoteDataSource`
4. Actualiza los endpoints con la API real

### URLs de Audio
Los URLs de audio en el código son ejemplos. Debes reemplazarlos con:
- URLs reales de Spotify API (preview_url)
- O tu propio servidor de streaming de audio

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:
1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto es solo para fines educativos.

## 👨‍💻 Autor

Creado con ❤️ usando Flutter y Clean Architecture

## � Usuarios de Prueba

Para probar la aplicación sin conexión a Spotify, puedes usar los siguientes usuarios demo:

### Usuario Demo
- **Nombre**: Gian Sandoval
- **Email**: giansando2022@gmail.com

El usuario se crea automáticamente la primera vez que ejecutas la aplicación.

## 🔐 Autenticación con Spotify

> 📖 **Guía Completa**: Ver [SPOTIFY_SETUP_GUIDE.md](SPOTIFY_SETUP_GUIDE.md) para configuración detallada

### OAuth 2.0 (Recomendado)
- Autenticación completa con Spotify
- Función de logout con cambio de usuario (`setShowDialog(true)`)
- Intercambio seguro de tokens
- Manejo automático de tokens de acceso y refresh

### SDK Directo
- Conexión directa con la aplicación Spotify
- Requiere Spotify instalado en el dispositivo
- Fallback a modo demo si falla

### Configuración Rápida OAuth
1. Registra tu app en [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. **CRÍTICO**: Agrega este Redirect URI exacto: `com.example.spotify-clone://auth`
3. Configura Client ID y Secret en `spotify_config.dart`
4. Los scopes incluidos: `user-read-private`, `user-read-email`, `streaming`, etc.

⚠️ **Error común**: Si ves "INVALID_CLIENT: Invalid redirect URI", verifica que agregaste exactamente `com.example.spotify-clone://auth` en el dashboard de Spotify.

## �🙏 Agradecimientos

- Flutter Team
- just_audio package
- Hive database
- Spotify por la inspiración del diseño
- Spotify SDK Android para OAuth implementation

---

⭐ Si te gustó este proyecto, no olvides darle una estrella!