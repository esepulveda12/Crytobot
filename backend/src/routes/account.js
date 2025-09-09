const express = require('express');
const binanceService = require('../services/binanceService');
const { getDecryptedCredentials, requireAuth } = require('./auth');
const logger = require('../utils/logger');

const router = express.Router();

// GET /api/account/balance - Obtener balance de la cuenta
router.get('/balance', requireAuth, async (req, res) => {
  try {
    const credentials = getDecryptedCredentials();
    binanceService.setCredentials(credentials.apiKey, credentials.secretKey);

    const balance = await binanceService.getAccountBalance();

    res.json({
      success: true,
      data: {
        balance: balance.total,
        available: balance.available,
        locked: balance.locked,
        currency: 'USDT',
        timestamp: new Date().toISOString()
      }
    });

  } catch (error) {
    logger.error('Error obteniendo balance:', error);
    res.status(500).json({
      success: false,
      message: 'Error obteniendo balance de la cuenta'
    });
  }
});

// GET /api/account/info - Obtener información de la cuenta
router.get('/info', requireAuth, async (req, res) => {
  try {
    const credentials = getDecryptedCredentials();
    binanceService.setCredentials(credentials.apiKey, credentials.secretKey);

    const balance = await binanceService.getAccountBalance();
    const testConnection = await binanceService.testConnection();

    res.json({
      success: true,
      data: {
        balance: balance.total,
        available: balance.available,
        locked: balance.locked,
        currency: 'USDT',
        connectionStatus: testConnection ? 'connected' : 'disconnected',
        timestamp: new Date().toISOString()
      }
    });

  } catch (error) {
    logger.error('Error obteniendo información de cuenta:', error);
    res.status(500).json({
      success: false,
      message: 'Error obteniendo información de la cuenta'
    });
  }
});

// GET /api/account/price/:symbol - Obtener precio actual de un símbolo
router.get('/price/:symbol', async (req, res) => {
  try {
    const { symbol } = req.params;
    const price = await binanceService.getCurrentPrice(symbol);

    res.json({
      success: true,
      data: {
        symbol: symbol,
        price: price,
        timestamp: new Date().toISOString()
      }
    });

  } catch (error) {
    logger.error(`Error obteniendo precio de ${req.params.symbol}:`, error);
    res.status(500).json({
      success: false,
      message: `Error obteniendo precio de ${req.params.symbol}`
    });
  }
});

// GET /api/account/symbols - Obtener lista de símbolos disponibles
router.get('/symbols', async (req, res) => {
  try {
    const symbols = [
      { symbol: 'BTCUSDT', base: 'BTC', quote: 'USDT', name: 'BTC/USDT' },
      { symbol: 'ETHUSDT', base: 'ETH', quote: 'USDT', name: 'ETH/USDT' },
      { symbol: 'BNBUSDT', base: 'BNB', quote: 'USDT', name: 'BNB/USDT' },
      { symbol: 'ADAUSDT', base: 'ADA', quote: 'USDT', name: 'ADA/USDT' },
      { symbol: 'SOLUSDT', base: 'SOL', quote: 'USDT', name: 'SOL/USDT' },
      { symbol: 'XRPUSDT', base: 'XRP', quote: 'USDT', name: 'XRP/USDT' },
      { symbol: 'DOTUSDT', base: 'DOT', quote: 'USDT', name: 'DOT/USDT' },
      { symbol: 'LINKUSDT', base: 'LINK', quote: 'USDT', name: 'LINK/USDT' }
    ];

    res.json({
      success: true,
      data: {
        symbols: symbols,
        count: symbols.length,
        timestamp: new Date().toISOString()
      }
    });

  } catch (error) {
    logger.error('Error obteniendo símbolos:', error);
    res.status(500).json({
      success: false,
      message: 'Error obteniendo lista de símbolos'
    });
  }
});

module.exports = router;
