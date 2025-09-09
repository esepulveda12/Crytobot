const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
const { createServer } = require('http');
const { WebSocketServer } = require('ws');
require('dotenv').config();

const logger = require('./utils/logger');
const binanceService = require('./services/binanceService');
const tradingBot = require('./services/tradingBot');
const authRoutes = require('./routes/auth');
const botRoutes = require('./routes/bot');
const accountRoutes = require('./routes/account');
const tradesRoutes = require('./routes/trades');

const app = express();
const server = createServer(app);
const wss = new WebSocketServer({ server });

// Middleware de seguridad
app.use(helmet());
app.use(compression());
app.use(morgan('combined', { stream: { write: message => logger.info(message.trim()) } }));

// CORS
app.use(cors({
  origin: process.env.CORS_ORIGIN || 'http://localhost:3000',
  credentials: true
}));

// Rate limiting
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000, // 15 minutos
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100,
  message: 'Demasiadas solicitudes desde esta IP'
});
app.use('/api/', limiter);

// Body parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Rutas
app.use('/api/auth', authRoutes);
app.use('/api/bot', botRoutes);
app.use('/api/account', accountRoutes);
app.use('/api/trades', tradesRoutes);

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// WebSocket para datos en tiempo real
wss.on('connection', (ws, req) => {
  logger.info('Nueva conexión WebSocket establecida');
  
  ws.on('message', (message) => {
    try {
      const data = JSON.parse(message);
      handleWebSocketMessage(ws, data);
    } catch (error) {
      logger.error('Error procesando mensaje WebSocket:', error);
    }
  });

  ws.on('close', () => {
    logger.info('Conexión WebSocket cerrada');
  });

  ws.on('error', (error) => {
    logger.error('Error en WebSocket:', error);
  });
});

function handleWebSocketMessage(ws, data) {
  switch (data.type) {
    case 'subscribe':
      // Suscribirse a actualizaciones de un par específico
      ws.pair = data.pair;
      logger.info(`Cliente suscrito a ${data.pair}`);
      break;
    case 'ping':
      ws.send(JSON.stringify({ type: 'pong' }));
      break;
  }
}

// Función para enviar datos a todos los clientes conectados
function broadcastToClients(data) {
  wss.clients.forEach((client) => {
    if (client.readyState === 1) { // WebSocket.OPEN
      client.send(JSON.stringify(data));
    }
  });
}

// Función para enviar datos a clientes suscritos a un par específico
function broadcastToPair(pair, data) {
  wss.clients.forEach((client) => {
    if (client.readyState === 1 && client.pair === pair) {
      client.send(JSON.stringify(data));
    }
  });
}

// Exportar funciones de broadcast para uso en otros módulos
global.broadcastToClients = broadcastToClients;
global.broadcastToPair = broadcastToPair;

// Inicializar servicios
async function initializeServices() {
  try {
    await binanceService.initialize();
    await tradingBot.initialize();
    logger.info('Servicios inicializados correctamente');
  } catch (error) {
    logger.error('Error inicializando servicios:', error);
  }
}

// Manejo de errores global
process.on('uncaughtException', (error) => {
  logger.error('Excepción no capturada:', error);
});

process.on('unhandledRejection', (reason, promise) => {
  logger.error('Promesa rechazada no manejada:', reason);
});

// Iniciar servidor
const PORT = process.env.PORT || 3000;
server.listen(PORT, async () => {
  logger.info(`Servidor iniciado en puerto ${PORT}`);
  await initializeServices();
});

module.exports = { app, server, wss };
