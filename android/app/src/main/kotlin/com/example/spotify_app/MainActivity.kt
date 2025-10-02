package com.example.spotify_app

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.spotify.sdk.android.auth.AuthorizationClient
import com.spotify.sdk.android.auth.AuthorizationRequest
import com.spotify.sdk.android.auth.AuthorizationResponse
import kotlinx.coroutines.*
import okhttp3.*
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject
import java.io.IOException
import java.util.*

class MainActivity : FlutterActivity() {
    private val CHANNEL = "spotify_auth"
    private val REQUEST_CODE = 1337
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "loginWithActivity" -> {
                    val clientId = call.argument<String>("clientId")
                    val redirectUri = call.argument<String>("redirectUri")
                    val scopes = call.argument<List<String>>("scopes")
                    
                    if (clientId != null && redirectUri != null && scopes != null) {
                        loginWithActivity(clientId, redirectUri, scopes.toTypedArray(), result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Missing required arguments", null)
                    }
                }
                "loginWithBrowser" -> {
                    val clientId = call.argument<String>("clientId")
                    val redirectUri = call.argument<String>("redirectUri")
                    val scopes = call.argument<List<String>>("scopes")
                    
                    if (clientId != null && redirectUri != null && scopes != null) {
                        loginWithBrowser(clientId, redirectUri, scopes.toTypedArray(), result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Missing required arguments", null)
                    }
                }
                "exchangeCodeForToken" -> {
                    val code = call.argument<String>("code")
                    val clientId = call.argument<String>("clientId")
                    val clientSecret = call.argument<String>("clientSecret")
                    val redirectUri = call.argument<String>("redirectUri")
                    
                    if (code != null && clientId != null && clientSecret != null && redirectUri != null) {
                        exchangeCodeForToken(code, clientId, clientSecret, redirectUri, result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Missing required arguments", null)
                    }
                }
                "logout" -> {
                    logout(result)
                }
                "logoutWithDialog" -> {
                    val clientId = call.argument<String>("clientId")
                    val redirectUri = call.argument<String>("redirectUri")
                    val scopes = call.argument<List<String>>("scopes")
                    
                    if (clientId != null && redirectUri != null && scopes != null) {
                        logoutWithDialog(clientId, redirectUri, scopes.toTypedArray(), result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Missing required arguments", null)
                    }
                }
                "hasActiveSession" -> {
                    hasActiveSession(result)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun loginWithActivity(clientId: String, redirectUri: String, scopes: Array<String>, result: MethodChannel.Result) {
        try {
            pendingResult = result
            
            val builder = AuthorizationRequest.Builder(clientId, AuthorizationResponse.Type.CODE, redirectUri)
            builder.setScopes(scopes)
            // Agregar showDialog para permitir cambio de usuario
            builder.setShowDialog(true)
            val request = builder.build()
            
            AuthorizationClient.openLoginActivity(this, REQUEST_CODE, request)
        } catch (e: Exception) {
            result.error("AUTH_ERROR", "Error starting login activity: ${e.message}", null)
        }
    }

    private fun loginWithBrowser(clientId: String, redirectUri: String, scopes: Array<String>, result: MethodChannel.Result) {
        try {
            pendingResult = result
            
            val builder = AuthorizationRequest.Builder(clientId, AuthorizationResponse.Type.CODE, redirectUri)
            builder.setScopes(scopes)
            // Agregar showDialog para permitir cambio de usuario
            builder.setShowDialog(true)
            val request = builder.build()
            
            AuthorizationClient.openLoginInBrowser(this, request)
        } catch (e: Exception) {
            result.error("AUTH_ERROR", "Error starting browser login: ${e.message}", null)
        }
    }

    private fun exchangeCodeForToken(code: String, clientId: String, clientSecret: String, redirectUri: String, result: MethodChannel.Result) {
        CoroutineScope(Dispatchers.IO).launch {
            try {
                val client = OkHttpClient()
                
                val credentials = Base64.getEncoder().encodeToString("$clientId:$clientSecret".toByteArray())
                
                val formBody = FormBody.Builder()
                    .add("grant_type", "authorization_code")
                    .add("code", code)
                    .add("redirect_uri", redirectUri)
                    .build()

                val request = Request.Builder()
                    .url("https://accounts.spotify.com/api/token")
                    .post(formBody)
                    .addHeader("Authorization", "Basic $credentials")
                    .addHeader("Content-Type", "application/x-www-form-urlencoded")
                    .build()

                client.newCall(request).enqueue(object : Callback {
                    override fun onFailure(call: Call, e: IOException) {
                        runOnUiThread {
                            result.error("NETWORK_ERROR", "Token exchange failed: ${e.message}", null)
                        }
                    }

                    override fun onResponse(call: Call, response: Response) {
                        runOnUiThread {
                            if (response.isSuccessful) {
                                val responseBody = response.body?.string()
                                if (responseBody != null) {
                                    try {
                                        val json = JSONObject(responseBody)
                                        val tokenData = mapOf(
                                            "access_token" to json.getString("access_token"),
                                            "token_type" to json.getString("token_type"),
                                            "expires_in" to json.getInt("expires_in"),
                                            "refresh_token" to json.optString("refresh_token", ""),
                                            "scope" to json.optString("scope", "")
                                        )
                                        result.success(tokenData)
                                    } catch (e: Exception) {
                                        result.error("PARSE_ERROR", "Error parsing token response: ${e.message}", null)
                                    }
                                } else {
                                    result.error("EMPTY_RESPONSE", "Empty response body", null)
                                }
                            } else {
                                result.error("HTTP_ERROR", "HTTP ${response.code}: ${response.message}", null)
                            }
                        }
                    }
                })
            } catch (e: Exception) {
                runOnUiThread {
                    result.error("UNEXPECTED_ERROR", "Unexpected error: ${e.message}", null)
                }
            }
        }
    }

    private fun logout(result: MethodChannel.Result) {
        try {
            // No hay método clearCookies en AuthorizationClient
            // En su lugar, simplemente reportamos éxito
            // La limpieza real de la sesión se hace en el lado de Dart
            result.success(true)
        } catch (e: Exception) {
            result.error("LOGOUT_ERROR", "Error during logout: ${e.message}", null)
        }
    }

    private fun logoutWithDialog(clientId: String, redirectUri: String, scopes: Array<String>, result: MethodChannel.Result) {
        try {
            pendingResult = result
            
            val builder = AuthorizationRequest.Builder(clientId, AuthorizationResponse.Type.CODE, redirectUri)
            builder.setScopes(scopes)
            // Forzar diálogo para permitir al usuario cerrar sesión eligiendo "¿No tú?"
            builder.setShowDialog(true)
            val request = builder.build()
            
            // Usar navegador para mejor experiencia de logout
            AuthorizationClient.openLoginInBrowser(this, request)
        } catch (e: Exception) {
            result.error("LOGOUT_ERROR", "Error during logout with dialog: ${e.message}", null)
        }
    }

    private fun hasActiveSession(result: MethodChannel.Result) {
        // Esta es una implementación simple - en una app real podrías verificar tokens guardados
        try {
            // Por simplicidad, siempre retornamos false y dependemos del flujo de autenticación
            result.success(false)
        } catch (e: Exception) {
            result.error("SESSION_CHECK_ERROR", "Error checking session: ${e.message}", null)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, intent: Intent?) {
        super.onActivityResult(requestCode, resultCode, intent)
        
        if (requestCode == REQUEST_CODE) {
            val response = AuthorizationClient.getResponse(resultCode, intent)
            handleAuthorizationResponse(response)
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        
        val uri = intent.data
        if (uri != null) {
            val response = AuthorizationResponse.fromUri(uri)
            handleAuthorizationResponse(response)
        }
    }

    private fun handleAuthorizationResponse(response: AuthorizationResponse) {
        val result = pendingResult ?: return
        pendingResult = null

        when (response.type) {
            AuthorizationResponse.Type.CODE -> {
                val responseData = mapOf(
                    "type" to "CODE",
                    "code" to response.code,
                    "state" to response.state
                )
                result.success(responseData)
            }
            AuthorizationResponse.Type.ERROR -> {
                result.error("AUTH_ERROR", "Authorization error: ${response.error}", null)
            }
            else -> {
                result.error("AUTH_CANCELLED", "Authorization was cancelled", null)
            }
        }
    }
}
