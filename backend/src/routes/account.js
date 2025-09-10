const express = require('express');
const binanceService = require('../services/binanceService');
const { getDecryptedCredentials, requireAuth } = require('./auth');
const logger = require('../utils/logger');

const router = express.Router();

// NOTA: Balance, símbolos y precios ahora se obtienen directamente desde Flutter a Binance
// Este archivo se mantiene solo para compatibilidad con estrategias y historial

// GET /api/account/symbols - Obtener símbolos de trading (para estrategias)
router.get('/symbols', async (req, res) => {
  try {
    const symbols = await binanceService.getSymbols();
    
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
      message: 'Error obteniendo símbolos de trading'
    });
  }
});

// GET /api/account/price/:symbol - Obtener precio actual de un símbolo (para estrategias)
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

// GET /api/account/klines/:symbol - Obtener datos de velas (para estrategias)
router.get('/klines/:symbol', async (req, res) => {
  try {
    const { symbol } = req.params;
    const { interval = '1h', limit = 100 } = req.query;
    
    const klines = await binanceService.getKlines(symbol, interval, limit);

    res.json({
      success: true,
      data: {
        symbol: symbol,
        interval: interval,
        klines: klines,
        count: klines.length,
        timestamp: new Date().toISOString()
      }
    });

  } catch (error) {
    logger.error(`Error obteniendo klines de ${req.params.symbol}:`, error);
    res.status(500).json({
      success: false,
      message: `Error obteniendo datos de velas de ${req.params.symbol}`
    });
  }
});

module.exports = { router };