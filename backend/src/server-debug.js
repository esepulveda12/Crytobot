const express = require('express');
require('dotenv').config();

const app = express();

// Middleware básico
app.use(express.json());

// Ruta de diagnóstico
app.get('/debug', (req, res) => {
  res.json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    environment: {
      NODE_ENV: process.env.NODE_ENV || 'NOT_SET',
      PORT: process.env.PORT || 'NOT_SET',
      CORS_ORIGIN: process.env.CORS_ORIGIN || 'NOT_SET',
      BINANCE_BASE_URL: process.env.BINANCE_BASE_URL || 'NOT_SET',
      BINANCE_WS_URL: process.env.BINANCE_WS_URL || 'NOT_SET',
      JWT_SECRET: process.env.JWT_SECRET ? 'SET' : 'NOT_SET',
      ENCRYPTION_KEY: process.env.ENCRYPTION_KEY ? 'SET' : 'NOT_SET',
      LOG_LEVEL: process.env.LOG_LEVEL || 'NOT_SET',
      RATE_LIMIT_WINDOW_MS: process.env.RATE_LIMIT_WINDOW_MS || 'NOT_SET',
      RATE_LIMIT_MAX_REQUESTS: process.env.RATE_LIMIT_MAX_REQUESTS || 'NOT_SET'
    }
  });
});

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// Ruta básica
app.get('/', (req, res) => {
  res.json({ 
    message: 'CryptoBot Spot Backend Debug Mode',
    timestamp: new Date().toISOString()
  });
});

// Iniciar servidor
const PORT = process.env.PORT || 10000;
app.listen(PORT, () => {
  console.log(`Servidor de diagnóstico iniciado en puerto ${PORT}`);
  console.log(`Debug: http://localhost:${PORT}/debug`);
  console.log(`Health: http://localhost:${PORT}/health`);
});

module.exports = app;
