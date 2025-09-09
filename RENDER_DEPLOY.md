# 🚀 Desplegar Backend en Render

## Pasos para desplegar en Render

### 1. **Preparar el repositorio**

1. **Subir el código a GitHub:**
```bash
git init
git add .
git commit -m "Initial commit - CryptoBot Spot Backend"
git branch -M main
git remote add origin https://github.com/tu-usuario/cryptobot-spot-backend.git
git push -u origin main
```

### 2. **Crear cuenta en Render**

1. Ve a [render.com](https://render.com)
2. Regístrate con tu cuenta de GitHub
3. Conecta tu repositorio

### 3. **Crear nuevo servicio Web**

1. **En el dashboard de Render:**
   - Click en "New +"
   - Selecciona "Web Service"
   - Conecta tu repositorio de GitHub

2. **Configuración del servicio:**
   - **Name**: `cryptobot-spot-backend`
   - **Environment**: `Node`
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
   - **Plan**: `Free` (para empezar)

### 4. **Variables de entorno**

Configura estas variables en Render:

```env
NODE_ENV=production
PORT=10000
CORS_ORIGIN=https://tu-app-flutter.onrender.com
BINANCE_BASE_URL=https://api.binance.com
BINANCE_WS_URL=wss://stream.binance.com:9443/ws
JWT_SECRET=tu_jwt_secret_muy_seguro_aqui_123456789012345678901234567890
ENCRYPTION_KEY=tu_clave_de_encriptacion_32_caracteres_123456789012345678901234567890
LOG_LEVEL=info
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
```

### 5. **Desplegar**

1. Click en "Create Web Service"
2. Render comenzará a construir y desplegar tu aplicación
3. Espera a que termine el proceso (5-10 minutos)

### 6. **Obtener URL del servicio**

Una vez desplegado, Render te dará una URL como:
```
https://cryptobot-spot-backend.onrender.com
```

### 7. **Actualizar Flutter App**

Actualiza la URL en tu app Flutter:

```dart
// En lib/services/api_service.dart
static const String baseUrl = 'https://cryptobot-spot-backend.onrender.com/api';

// En lib/services/websocket_service.dart
_channel = IOWebSocketChannel.connect('wss://cryptobot-spot-backend.onrender.com');
```

## 🔧 **Configuración adicional**

### **WebSocket en Render**

Render soporta WebSocket, pero necesitas:

1. **Habilitar WebSocket** en la configuración del servicio
2. **Usar HTTPS/WSS** para conexiones seguras
3. **Configurar CORS** correctamente

### **Variables de entorno seguras**

- **JWT_SECRET**: Genera una clave aleatoria de 64 caracteres
- **ENCRYPTION_KEY**: Debe ser exactamente 32 caracteres
- **CORS_ORIGIN**: URL de tu app Flutter (si la despliegas también)

### **Monitoreo**

- **Logs**: Disponibles en el dashboard de Render
- **Métricas**: CPU, memoria, requests
- **Uptime**: Monitoreo automático

## ⚠️ **Consideraciones importantes**

### **Plan Gratuito de Render**
- **Sleep mode**: Se duerme después de 15 min de inactividad
- **Cold start**: 30-60 segundos para despertar
- **Límites**: 750 horas/mes gratis

### **Para producción**
- Considera el plan **Starter** ($7/mes) para evitar sleep mode
- Configura **custom domain**
- Implementa **health checks**

## 🚀 **Después del despliegue**

1. **Probar endpoints:**
```bash
curl https://cryptobot-spot-backend.onrender.com/health
```

2. **Verificar WebSocket:**
```javascript
const ws = new WebSocket('wss://cryptobot-spot-backend.onrender.com');
ws.onopen = () => console.log('Connected!');
```

3. **Actualizar Flutter app** con la nueva URL

4. **Probar autenticación** con credenciales reales de Binance

## 📞 **Soporte**

Si tienes problemas:
- Revisa los logs en Render dashboard
- Verifica las variables de entorno
- Comprueba la conectividad con Binance
- Contacta al equipo de desarrollo

---

¡Tu backend estará disponible 24/7 en la nube! 🌐
