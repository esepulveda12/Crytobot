# CryptoBot Spot - Instrucciones de Instalación y Uso

## 🚀 Instalación Completa

### 1. Backend (Node.js)

1. **Navegar al directorio del backend:**
```bash
cd crypto_bot_spot/backend
```

2. **Instalar dependencias:**
```bash
npm install
```

3. **Configurar variables de entorno:**
```bash
cp env.example .env
```

4. **Editar el archivo `.env` con tus configuraciones:**
```env
PORT=3000
CORS_ORIGIN=http://localhost:3000
BINANCE_BASE_URL=https://api.binance.com
BINANCE_WS_URL=wss://stream.binance.com:9443/ws
JWT_SECRET=tu_jwt_secret_muy_seguro_aqui_123456789012345678901234567890
ENCRYPTION_KEY=tu_clave_de_encriptacion_32_caracteres_123456789012345678901234567890
LOG_LEVEL=info
LOG_FILE=logs/cryptobot.log
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
```

5. **Iniciar el backend:**
```bash
# Desarrollo (con auto-reload)
npm run dev

# Producción
npm start
```

El backend estará disponible en `http://localhost:3000`

### 2. Flutter App

1. **Navegar al directorio principal:**
```bash
cd crypto_bot_spot
```

2. **Instalar dependencias de Flutter:**
```bash
flutter pub get
```

3. **Ejecutar la aplicación:**
```bash
# Android
flutter run

# iOS
flutter run -d ios

# Web
flutter run -d web
```

## 🔑 Configuración de Binance

### 1. Crear API Keys en Binance

1. Ve a [Binance.com](https://www.binance.com)
2. Inicia sesión en tu cuenta
3. Ve a **API Management** en tu perfil
4. Crea una nueva API Key con los siguientes permisos:
   - ✅ **Enable Spot & Margin Trading**
   - ❌ **Enable Futures** (NO habilitar)
   - ❌ **Enable Withdrawals** (NO habilitar)

### 2. Configurar Restricciones de IP (Recomendado)

- Agrega tu IP actual para mayor seguridad
- O deja en blanco para desarrollo (menos seguro)

## 📱 Uso de la Aplicación

### 1. Pantalla de Login

1. **Abrir la app** - Verás la pantalla de login
2. **Ingresar credenciales:**
   - API Key de Binance
   - Secret Key de Binance
3. **Hacer clic en "Guardar y Conectar"**
4. La app validará las credenciales con Binance

### 2. Dashboard Principal

Una vez autenticado, verás:

- **Balance USDT** - Tu balance disponible
- **Estado del Bot** - Activo/Inactivo
- **Configuración del Bot:**
  - Par de trading (BTC/USDT, ETH/USDT, etc.)
  - Pullback para comprar (1-10%)
  - Target de ganancia (1-15%)
  - Confirmación EMA (opcional)
  - Trailing Stop (opcional)
- **Logs en tiempo real** - Actividad del bot

### 3. Estrategia de Trading

El bot implementa:

1. **Análisis de tendencia** con EMA9 y EMA21
2. **Detección de pullback** - Compra cuando el precio baja X% desde el máximo
3. **Take profit** - Vende automáticamente al alcanzar +X% de ganancia
4. **Trailing stop** - Mueve el stop loss cuando el precio sube

### 4. Navegación

- **Dashboard** - Control principal del bot
- **Historial** - Ver trades anteriores
- **Logs** - Logs detallados del bot
- **Configuración** - Ajustes de la app

## ⚠️ Consideraciones Importantes

### Seguridad
- ✅ Las credenciales se almacenan encriptadas
- ✅ Solo trading Spot (sin futuros)
- ✅ Rate limiting para prevenir abuso
- ⚠️ **NUNCA compartas tus API keys**

### Trading
- ⚠️ **Usar con precaución** - El trading automatizado conlleva riesgos
- ⚠️ **Empezar con cantidades pequeñas** para probar
- ⚠️ **Monitorear el bot** regularmente
- ⚠️ **Verificar configuraciones** antes de iniciar

### Desarrollo
- El backend debe estar corriendo para que la app funcione
- Los logs se guardan en `backend/logs/`
- WebSocket para datos en tiempo real

## 🛠️ Solución de Problemas

### Backend no inicia
```bash
# Verificar que Node.js esté instalado
node --version

# Verificar puerto 3000 disponible
netstat -an | grep 3000

# Reinstalar dependencias
rm -rf node_modules package-lock.json
npm install
```

### App Flutter no conecta
1. Verificar que el backend esté corriendo en `http://localhost:3000`
2. Verificar la URL en `lib/services/api_service.dart`
3. Verificar permisos de red en el dispositivo

### Error de autenticación
1. Verificar que las API keys sean correctas
2. Verificar que tengan permisos de Spot Trading
3. Verificar restricciones de IP en Binance

### Bot no opera
1. Verificar que tengas balance USDT suficiente
2. Verificar que el par seleccionado sea válido
3. Verificar logs para errores específicos

## 📊 Monitoreo

### Logs del Backend
```bash
# Ver logs en tiempo real
tail -f backend/logs/combined.log

# Ver solo errores
tail -f backend/logs/error.log
```

### Estado del Bot
- Revisar logs en la app
- Verificar balance en Binance
- Monitorear trades en Binance

## 🔄 Actualizaciones

### Backend
```bash
cd backend
git pull
npm install
npm start
```

### Flutter
```bash
flutter pub get
flutter run
```

## 📞 Soporte

Si encuentras problemas:

1. Revisar logs del backend
2. Verificar configuración de Binance
3. Verificar conectividad de red
4. Contactar al equipo de desarrollo

---

**¡Importante!** Esta aplicación es para fines educativos. El trading automatizado conlleva riesgos financieros. Usa con precaución y nunca inviertas más de lo que puedes permitirte perder.
