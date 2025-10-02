# 🎵 Guía de Configuración de Spotify OAuth

## 🔑 Configuración en Spotify Developer Dashboard

Para que la autenticación OAuth funcione correctamente, debes configurar tu aplicación en el Spotify Developer Dashboard.

### 1. Crear/Editar Aplicación en Spotify

1. Ve a [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Inicia sesión con tu cuenta de Spotify
3. Si no tienes una aplicación, haz clic en "Create app"
4. Si ya tienes una aplicación, selecciónala y haz clic en "Settings"

### 2. Configuración de Redirect URIs

**CRÍTICO:** Debes agregar exactamente este Redirect URI en la configuración de tu app:

```
com.example.spotify-clone://auth
```

#### Pasos para agregar Redirect URI:
1. En la configuración de tu app, busca la sección "Redirect URIs"
2. Haz clic en "Add Redirect URI"
3. Ingresa exactamente: `com.example.spotify-clone://auth`
4. Haz clic en "Save"

### 3. Credenciales de la Aplicación

Asegúrate de que las credenciales en `spotify_config.dart` coincidan con tu app:

```dart
static const String clientId = 'TU_CLIENT_ID_AQUÍ';
static const String clientSecret = 'TU_CLIENT_SECRET_AQUÍ';
```

⚠️ **IMPORTANTE:** Nunca publiques tu `clientSecret` en repositorios públicos.

### 4. Scopes Configurados

La aplicación solicita los siguientes permisos (scopes):
- `user-read-private` - Leer información básica del perfil
- `user-read-email` - Leer dirección de email
- `user-read-playback-state` - Leer estado de reproducción
- `user-modify-playback-state` - Controlar reproducción
- `user-read-currently-playing` - Ver canción actual
- `streaming` - Reproducir música via Web API
- `app-remote-control` - Control remoto via SDK

## 🔧 Solución de Problemas

### Error "INVALID_CLIENT: Invalid redirect URI"

Este error significa que el redirect URI no está registrado en tu aplicación de Spotify:

1. ✅ Verifica que agregaste exactamente: `com.example.spotify-clone://auth`
2. ✅ Asegúrate de hacer clic en "Save" en el dashboard
3. ✅ Espera unos minutos para que los cambios se propaguen

### Error "User has logged out from Spotify"

Este error puede ocurrir cuando:
1. El usuario cerró sesión en la app de Spotify
2. No hay una sesión activa en el dispositivo
3. La app de Spotify no está instalada

**Soluciones:**
- Usar OAuth en navegador (recomendado)
- Abrir Spotify app y hacer login manualmente
- Usar el botón "OAuth con Spotify (Recomendado)" en lugar de "SDK Directo"

### Error "MissingPluginException"

Si ves este error, significa que hay un problema con la implementación nativa:

1. ✅ Verifica que `MainActivity.kt` esté correctamente configurado
2. ✅ Ejecuta `flutter clean && flutter pub get`
3. ✅ Reconstruye la aplicación completamente

## 🎯 Métodos de Autenticación Disponibles

### 1. OAuth con Spotify (Recomendado) 🟢
- ✅ Funciona sin Spotify app instalada
- ✅ Permite cambio de usuario con `setShowDialog(true)`
- ✅ Más seguro y confiable
- ✅ Funciona en emuladores

### 2. SDK Directo 🟡
- ⚠️ Requiere Spotify app instalada
- ⚠️ Solo funciona en dispositivos reales
- ⚠️ Puede fallar si el usuario no tiene sesión activa

### 3. Login con Email (Demo) 🔵
- ✅ Para testing sin Spotify
- ✅ Usa usuarios locales predefinidos
- ⚠️ No proporciona funcionalidad real de Spotify

## 🚀 Flujo de Autenticación Completo

1. **Usuario hace clic en "OAuth con Spotify"**
2. **Se abre navegador con login de Spotify**
3. **Usuario ingresa credenciales**
4. **Spotify redirige a: `com.example.spotify-clone://auth?code=...`**
5. **App captura el código de autorización**
6. **Se intercambia código por access_token**
7. **Se guardan tokens y datos del usuario**
8. **Navegación a pantalla principal**

## ⚙️ Configuración para Desarrollo

### Para Testing Local:
1. Usa Client ID y Secret de desarrollo
2. Agrega redirect URI de desarrollo
3. Configura dominio localhost si es necesario

### Para Producción:
1. Crea aplicación separada en Spotify Dashboard
2. Usa credenciales de producción
3. Configura redirect URI de producción
4. Solicita aprobación de Spotify para uso público

## 📱 Plataformas Soportadas

- ✅ **Android**: Completamente implementado
- 🔄 **iOS**: Requiere configuración adicional en `Info.plist`
- ❌ **Web**: No soportado por Spotify SDK

## 🔐 Seguridad

### Buenas Prácticas:
- 🔒 Nunca expongas `clientSecret` en código cliente
- 🔒 Usa PKCE para flujos OAuth más seguros
- 🔒 Valida redirect URIs en servidor
- 🔒 Implementa refresh token rotation
- 🔒 Usa HTTPS en producción

### Variables de Entorno (Recomendado):
```bash
SPOTIFY_CLIENT_ID=tu_client_id
SPOTIFY_CLIENT_SECRET=tu_client_secret
```

## 📞 Soporte

Si encuentras problemas:
1. Revisa logs en consola (`flutter logs`)
2. Verifica configuración en Spotify Dashboard
3. Consulta [Documentación oficial de Spotify](https://developer.spotify.com/documentation/)
4. Revisa [Issues en GitHub](https://github.com/spotify/android-sdk/issues)

---
💡 **Tip**: Siempre usa "OAuth con Spotify (Recomendado)" para la mejor experiencia de usuario.