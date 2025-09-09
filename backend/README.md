# CryptoBot Spot - Backend

Backend para la aplicación CryptoBot Spot que se conecta directamente a la API de Binance para trading automatizado.

## Características

- 🔐 **Autenticación segura** con encriptación de credenciales
- 📊 **Integración completa** con Binance Spot Trading API
- 🤖 **Bot de trading inteligente** con estrategias EMA y trailing stop
- ⚡ **WebSocket** para datos en tiempo real
- 📈 **Análisis técnico** con medias móviles exponenciales
- 🛡️ **Seguridad robusta** con rate limiting y validación

## Instalación

1. **Instalar dependencias:**
```bash
cd backend
npm install
```

2. **Configurar variables de entorno:**
```bash
cp env.example .env
```

Editar el archivo `.env` con tus configuraciones:
```env
PORT=3000
CORS_ORIGIN=http://localhost:3000
BINANCE_BASE_URL=https://api.binance.com
BINANCE_WS_URL=wss://stream.binance.com:9443/ws
JWT_SECRET=tu_jwt_secret_muy_seguro_aqui
ENCRYPTION_KEY=tu_clave_de_encriptacion_32_caracteres
```

3. **Iniciar el servidor:**
```bash
# Desarrollo
npm run dev

# Producción
npm start
```

## API Endpoints

### Autenticación
- `POST /api/auth/login` - Autenticar con credenciales de Binance
- `POST /api/auth/logout` - Cerrar sesión
- `GET /api/auth/status` - Verificar estado de autenticación

### Cuenta
- `GET /api/account/balance` - Obtener balance USDT
- `GET /api/account/info` - Información completa de la cuenta
- `GET /api/account/price/:symbol` - Precio actual de un símbolo
- `GET /api/account/symbols` - Lista de símbolos disponibles

### Bot de Trading
- `POST /api/bot/start` - Iniciar el bot
- `POST /api/bot/stop` - Detener el bot
- `GET /api/bot/status` - Estado actual del bot
- `GET /api/bot/logs` - Logs del bot en tiempo real
- `PUT /api/bot/config` - Actualizar configuración
- `GET /api/bot/analytics` - Datos analíticos del bot

### Trades
- `GET /api/trades/history` - Historial de trades
- `GET /api/trades/current` - Posición actual
- `GET /api/trades/performance` - Rendimiento del bot

## Estrategia de Trading

El bot implementa una estrategia de trading basada en:

1. **Análisis de tendencia** con EMA9 y EMA21
2. **Detección de pullback** configurable (1-10%)
3. **Take profit** configurable (1-15%)
4. **Trailing stop** opcional (1-5%)
5. **Solo trading Spot** (sin futuros)

### Parámetros Configurables

- **Par de trading**: BTC/USDT, ETH/USDT, BNB/USDT, etc.
- **Pullback para comprar**: 1-10%
- **Target de ganancia**: 1-15%
- **Confirmación EMA**: Opcional
- **Trailing stop**: Opcional con porcentaje configurable

## WebSocket

El servidor incluye WebSocket para datos en tiempo real:

```javascript
const ws = new WebSocket('ws://localhost:3000');

// Suscribirse a un par
ws.send(JSON.stringify({
  type: 'subscribe',
  pair: 'BTCUSDT'
}));

// Escuchar actualizaciones
ws.onmessage = (event) => {
  const data = JSON.parse(event.data);
  console.log(data);
};
```

## Seguridad

- ✅ Encriptación AES-256 para credenciales
- ✅ Rate limiting para prevenir abuso
- ✅ Validación de entrada en todos los endpoints
- ✅ Headers de seguridad con Helmet
- ✅ CORS configurado
- ✅ Logging completo de todas las operaciones

## Estructura del Proyecto

```
backend/
├── src/
│   ├── routes/          # Endpoints de la API
│   ├── services/        # Lógica de negocio
│   ├── utils/           # Utilidades y helpers
│   └── server.js        # Servidor principal
├── logs/               # Archivos de log
├── package.json
└── README.md
```

## Desarrollo

Para desarrollo local:

1. Instalar dependencias: `npm install`
2. Configurar `.env` con tus credenciales
3. Ejecutar: `npm run dev`
4. El servidor estará disponible en `http://localhost:3000`

## Producción

Para despliegue en producción:

1. Configurar variables de entorno de producción
2. Instalar dependencias: `npm install --production`
3. Ejecutar: `npm start`
4. Configurar proxy reverso (nginx/apache)
5. Configurar SSL/TLS

## Notas Importantes

- ⚠️ **Solo para trading Spot** - No incluye futuros
- ⚠️ **Usar con precaución** - El trading automatizado conlleva riesgos
- ⚠️ **Credenciales seguras** - Nunca compartas tus API keys
- ⚠️ **Testing primero** - Prueba con cantidades pequeñas

## Soporte

Para soporte técnico o reportar bugs, contacta al equipo de desarrollo.
