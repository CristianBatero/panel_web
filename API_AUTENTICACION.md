# 🔐 API de Autenticación - Guía para Desarrolladores

## Endpoint de Verificación de Usuarios

### URL
```
POST http://TU_SERVIDOR:5000/api/auth/verify
```

### Sin Autenticación
Este endpoint NO requiere autenticación (no necesitas estar logueado en el panel).

## Request

### Headers
```
Content-Type: application/json
```

### Body (Usuario con Contraseña)
```json
{
  "username": "usuario123",
  "password": "contraseña"
}
```

### Body (Usuario con Token/ID)
```json
{
  "username": "device_12345"
}
```

## Responses

### ✅ Usuario Autenticado (200 OK)
```json
{
  "authenticated": true,
  "user": {
    "username": "usuario123",
    "alias": "Usuario Demo",
    "type": "password",
    "expiry_date": "2026-04-06",
    "days_remaining": 30,
    "status": "activo"
  }
}
```

### ❌ Usuario No Encontrado (404)
```json
{
  "error": "Usuario no encontrado",
  "authenticated": false
}
```

### ❌ Contraseña Incorrecta (401)
```json
{
  "error": "Contraseña incorrecta",
  "authenticated": false
}
```

### ❌ Usuario Expirado (403)
```json
{
  "error": "Usuario expirado",
  "authenticated": false,
  "expired": true,
  "expiry_date": "2026-01-01"
}
```

### ❌ Error del Servidor (500)
```json
{
  "error": "Descripción del error",
  "authenticated": false
}
```

## Implementación en Android

### Usando OkHttp

```java
import okhttp3.*;
import org.json.JSONObject;

public class AuthManager {
    private static final String BASE_URL = "http://tu-servidor.com:5000";
    private OkHttpClient client = new OkHttpClient();
    
    public void verifyUser(String username, String password, AuthCallback callback) {
        try {
            // Crear JSON
            JSONObject json = new JSONObject();
            json.put("username", username);
            if (password != null && !password.isEmpty()) {
                json.put("password", password);
            }
            
            // Crear request
            RequestBody body = RequestBody.create(
                json.toString(),
                MediaType.parse("application/json")
            );
            
            Request request = new Request.Builder()
                .url(BASE_URL + "/api/auth/verify")
                .post(body)
                .build();
            
            // Ejecutar
            client.newCall(request).enqueue(new Callback() {
                @Override
                public void onResponse(Call call, Response response) throws IOException {
                    String responseBody = response.body().string();
                    
                    try {
                        JSONObject result = new JSONObject(responseBody);
                        
                        if (response.isSuccessful() && result.getBoolean("authenticated")) {
                            // Usuario autenticado
                            JSONObject user = result.getJSONObject("user");
                            callback.onSuccess(user);
                        } else {
                            // Error de autenticación
                            String error = result.optString("error", "Error desconocido");
                            callback.onError(error);
                        }
                    } catch (Exception e) {
                        callback.onError("Error al procesar respuesta");
                    }
                }
                
                @Override
                public void onFailure(Call call, IOException e) {
                    callback.onError("Error de conexión: " + e.getMessage());
                }
            });
            
        } catch (Exception e) {
            callback.onError("Error: " + e.getMessage());
        }
    }
    
    public interface AuthCallback {
        void onSuccess(JSONObject user);
        void onError(String error);
    }
}
```

### Uso en Activity

```java
public class LoginActivity extends AppCompatActivity {
    private AuthManager authManager;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);
        
        authManager = new AuthManager();
        
        Button btnLogin = findViewById(R.id.btnLogin);
        EditText etUsername = findViewById(R.id.etUsername);
        EditText etPassword = findViewById(R.id.etPassword);
        
        btnLogin.setOnClickListener(v -> {
            String username = etUsername.getText().toString();
            String password = etPassword.getText().toString();
            
            authManager.verifyUser(username, password, new AuthManager.AuthCallback() {
                @Override
                public void onSuccess(JSONObject user) {
                    runOnUiThread(() -> {
                        try {
                            String username = user.getString("username");
                            int daysRemaining = user.getInt("days_remaining");
                            
                            // Guardar sesión
                            SharedPreferences prefs = getSharedPreferences("user", MODE_PRIVATE);
                            prefs.edit()
                                .putString("username", username)
                                .putInt("days_remaining", daysRemaining)
                                .putBoolean("logged_in", true)
                                .apply();
                            
                            // Ir a MainActivity
                            startActivity(new Intent(LoginActivity.this, MainActivity.class));
                            finish();
                            
                        } catch (Exception e) {
                            Toast.makeText(LoginActivity.this, "Error al procesar datos", Toast.LENGTH_SHORT).show();
                        }
                    });
                }
                
                @Override
                public void onError(String error) {
                    runOnUiThread(() -> {
                        Toast.makeText(LoginActivity.this, error, Toast.LENGTH_SHORT).show();
                    });
                }
            });
        });
    }
}
```

### Usando Retrofit (Alternativa)

```java
// Interface
public interface ApiService {
    @POST("/api/auth/verify")
    Call<AuthResponse> verifyUser(@Body AuthRequest request);
}

// Request
public class AuthRequest {
    private String username;
    private String password;
    
    public AuthRequest(String username, String password) {
        this.username = username;
        this.password = password;
    }
}

// Response
public class AuthResponse {
    private boolean authenticated;
    private User user;
    private String error;
    
    // Getters y setters
}

public class User {
    private String username;
    private String alias;
    private String type;
    private String expiry_date;
    private int days_remaining;
    private String status;
    
    // Getters y setters
}

// Uso
Retrofit retrofit = new Retrofit.Builder()
    .baseUrl("http://tu-servidor.com:5000")
    .addConverterFactory(GsonConverterFactory.create())
    .build();

ApiService api = retrofit.create(ApiService.class);

AuthRequest request = new AuthRequest(username, password);
api.verifyUser(request).enqueue(new Callback<AuthResponse>() {
    @Override
    public void onResponse(Call<AuthResponse> call, Response<AuthResponse> response) {
        if (response.isSuccessful() && response.body().isAuthenticated()) {
            User user = response.body().getUser();
            // Usuario autenticado
        } else {
            // Error
        }
    }
    
    @Override
    public void onFailure(Call<AuthResponse> call, Throwable t) {
        // Error de conexión
    }
});
```

## Flujo de Autenticación Recomendado

### 1. Login
```
Usuario ingresa credenciales
    ↓
POST /api/auth/verify
    ↓
Si authenticated = true:
    - Guardar datos en SharedPreferences
    - Ir a MainActivity
Si authenticated = false:
    - Mostrar error
    - Permitir reintentar
```

### 2. Verificación en Cada Inicio
```
App inicia
    ↓
Verificar SharedPreferences
    ↓
Si logged_in = true:
    - Verificar usuario nuevamente (opcional)
    - Ir a MainActivity
Si logged_in = false:
    - Ir a LoginActivity
```

### 3. Verificación Periódica (Opcional)
```
Cada X horas:
    - POST /api/auth/verify
    - Actualizar days_remaining
    - Si expirado, cerrar sesión
```

## Tipos de Usuario

### Usuario con Contraseña
```json
{
  "username": "usuario123",
  "password": "contraseña"
}
```
- Requiere contraseña para autenticar
- Típico para usuarios normales

### Usuario con Token/ID
```json
{
  "username": "device_abc123"
}
```
- NO requiere contraseña
- Autenticación solo por username (device ID)
- Típico para licencias por dispositivo

## Manejo de Errores

### Error de Conexión
```java
catch (IOException e) {
    // No hay internet o servidor no responde
    Toast.makeText(this, "Error de conexión", Toast.LENGTH_SHORT).show();
}
```

### Usuario Expirado
```java
if (result.has("expired") && result.getBoolean("expired")) {
    String expiryDate = result.getString("expiry_date");
    Toast.makeText(this, "Tu suscripción expiró el " + expiryDate, Toast.LENGTH_LONG).show();
    // Mostrar opción de renovar
}
```

### Contraseña Incorrecta
```java
if (result.getString("error").contains("Contraseña incorrecta")) {
    Toast.makeText(this, "Contraseña incorrecta", Toast.LENGTH_SHORT).show();
    // Limpiar campo de contraseña
}
```

## Seguridad

### ⚠️ Importante
- Las contraseñas se envían en texto plano
- Usa HTTPS en producción
- No guardes contraseñas en SharedPreferences
- Solo guarda el estado de autenticación

### Recomendaciones
1. Implementar HTTPS con certificado SSL
2. Usar tokens de sesión en lugar de contraseñas
3. Implementar rate limiting en el servidor
4. Agregar captcha después de X intentos fallidos

## Testing

### Con cURL
```bash
# Usuario con contraseña
curl -X POST http://localhost:5000/api/auth/verify \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"1234"}'

# Usuario con token
curl -X POST http://localhost:5000/api/auth/verify \
  -H "Content-Type: application/json" \
  -d '{"username":"device_abc123"}'
```

### Con Postman
1. Método: POST
2. URL: http://tu-servidor:5000/api/auth/verify
3. Headers: Content-Type: application/json
4. Body (raw JSON):
```json
{
  "username": "test",
  "password": "1234"
}
```

## Resumen

- **Endpoint:** POST `/api/auth/verify`
- **Sin autenticación:** No requiere login en el panel
- **Tipos:** Contraseña o Token (device ID)
- **Response:** JSON con `authenticated` y datos del usuario
- **Errores:** 404 (no encontrado), 401 (contraseña incorrecta), 403 (expirado)

El endpoint está listo para usar desde tu aplicación Android.
