# 📋 Comandos Útiles - Spotify Clone

## 🚀 Comandos de Inicio Rápido

### Instalar todas las dependencias
```bash
flutter pub get
```

### Generar archivos de Hive (IMPORTANTE - Ejecutar antes de la primera vez)
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Ejecutar en modo debug
```bash
flutter run
```

### Ejecutar en modo release (más rápido)
```bash
flutter run --release
```

## 🔧 Comandos de Desarrollo

### Ver dispositivos disponibles
```bash
flutter devices
```

### Ejecutar en un dispositivo específico
```bash
flutter run -d <device-id>
```

### Hot Reload (durante la ejecución)
Presiona `r` en la terminal

### Hot Restart (durante la ejecución)
Presiona `R` en la terminal

### Limpiar el proyecto
```bash
flutter clean
flutter pub get
```

## 🏗️ Build Runner

### Generar archivos (sin borrar conflictos)
```bash
flutter packages pub run build_runner build
```

### Generar archivos (borrando conflictos - RECOMENDADO)
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Watch mode (regenera automáticamente)
```bash
flutter packages pub run build_runner watch --delete-conflicting-outputs
```

## 📱 Comandos de Build

### Build APK (Android)
```bash
flutter build apk --release
```

### Build App Bundle (Android - para Google Play)
```bash
flutter build appbundle --release
```

### Build iOS (requiere Mac)
```bash
flutter build ios --release
```

## 🧪 Testing

### Ejecutar todos los tests
```bash
flutter test
```

### Ejecutar tests con cobertura
```bash
flutter test --coverage
```

## 🔍 Análisis de Código

### Analizar el código
```bash
flutter analyze
```

### Formatear el código
```bash
dart format lib/
```

## 📦 Gestión de Paquetes

### Actualizar dependencias
```bash
flutter pub upgrade
```

### Ver dependencias obsoletas
```bash
flutter pub outdated
```

### Obtener información de un paquete
```bash
flutter pub deps
```

## 🐛 Debugging

### Ver logs en tiempo real
```bash
flutter logs
```

### Inspeccionar el widget tree
```bash
flutter run --observatory-port=8888
```
Luego abre: http://localhost:8888

## 📊 Performance

### Verificar performance
```bash
flutter run --profile
```

### Medir el tamaño del APK
```bash
flutter build apk --analyze-size
```

## 🗑️ Limpieza Profunda

Si tienes problemas, ejecuta estos comandos en orden:

```bash
# 1. Limpiar Flutter
flutter clean

# 2. Limpiar pub cache
flutter pub cache repair

# 3. Reinstalar dependencias
flutter pub get

# 4. Regenerar archivos de Hive
flutter packages pub run build_runner build --delete-conflicting-outputs

# 5. Reconstruir
flutter run
```

## 🔐 Permisos Android

### Ver permisos del APK
```bash
aapt dump permissions build/app/outputs/flutter-apk/app-release.apk
```

## 📱 Instalación Manual

### Instalar APK en dispositivo conectado
```bash
flutter install
```

### Instalar APK específico
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

## 🎯 Comandos de Hive

### Limpiar caché de Hive (en código Dart)
```dart
// En tu código:
await Hive.deleteBoxFromDisk('favorites');
await Hive.deleteBoxFromDisk('recently_played');
```

## 📝 Estructura de Archivos Generados

Después de ejecutar build_runner, deberías ver:
```
lib/data/models/
  ├── song_model.dart          # Tu modelo
  └── song_model.g.dart        # Generado automáticamente
```

## ⚠️ Errores Comunes y Soluciones

### Error: "Hive adapters not registered"
**Solución:**
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Error: "Conflicting outputs"
**Solución:**
Usa el flag `--delete-conflicting-outputs` en build_runner

### Error: "MissingPluginException"
**Solución:**
```bash
flutter clean
flutter pub get
flutter run
```

### Error: "Cannot find audio_service"
**Solución:**
Verifica que AndroidManifest.xml tenga la configuración del servicio

## 🎨 VS Code - Tareas Útiles

Crea `.vscode/tasks.json`:
```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Build Runner",
      "type": "shell",
      "command": "flutter packages pub run build_runner build --delete-conflicting-outputs",
      "problemMatcher": []
    },
    {
      "label": "Clean & Get",
      "type": "shell",
      "command": "flutter clean && flutter pub get",
      "problemMatcher": []
    }
  ]
}
```

## 📱 Comandos de Emulador

### Listar emuladores disponibles
```bash
flutter emulators
```

### Iniciar un emulador
```bash
flutter emulators --launch <emulator-id>
```

### Crear un nuevo emulador Android
```bash
avdmanager create avd -n pixel_5 -k "system-images;android-31;google_apis;x86_64"
```

## 🔄 Git Hooks Recomendados

Crea `.git/hooks/pre-commit`:
```bash
#!/bin/sh
flutter analyze
flutter test
```

## 📖 Documentación

### Generar documentación del código
```bash
dart doc .
```

---

💡 **Tip:** Guarda este archivo en tu proyecto para referencia rápida!

🎯 **Recomendación:** Ejecuta estos comandos en orden la primera vez:
1. `flutter pub get`
2. `flutter packages pub run build_runner build --delete-conflicting-outputs`
3. `flutter run`