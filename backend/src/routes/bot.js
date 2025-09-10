const express = require('express');
const tradingBot = require('../services/tradingBot');
const logger = require('../utils/logger');

const router = express.Router();

// POST /api/bot/start - Iniciar el bot de trading (estrategias)
router.post('/start', async (req, res) => {
  try {
    const { selectedPair, pullbackPercent, profitTarget, useEMA, trailingStop, trailingPercent, apiKey, secretKey } = req.body;

    // Validar parámetros requeridos
    if (!selectedPair || !pullbackPercent || !profitTarget) {
      return res.status(400).json({
        success: false,
        message: 'Parámetros requeridos: selectedPair, pullbackPercent, profitTarget'
      });
    }

    // Validar credenciales
    if (!apiKey || !secretKey) {
      return res.status(400).json({
        success: false,
        message: 'Credenciales requeridas: apiKey, secretKey'
      });
    }
    
    const config = {
      selectedPair,
      pullbackPercent: parseFloat(pullbackPercent),
      profitTarget: parseFloat(profitTarget),
      useEMA: useEMA || false,
      trailingStop: trailingStop || false,
      trailingPercent: parseFloat(trailingPercent) || 2.0,
      apiKey: apiKey,
      secretKey: secretKey
    };

    const success = await tradingBot.startBot(config);

    if (success) {
      res.json({
        success: true,
        message: 'Bot iniciado correctamente',
        data: {
          status: 'running',
          config: config,
          timestamp: new Date().toISOString()
        }
      });
    } else {
      res.status(500).json({
        success: false,
        message: 'Error iniciando el bot'
      });
    }

  } catch (error) {
    logger.error('Error iniciando bot:', error);
    res.status(500).json({
      success: false,
      message: 'Error interno del servidor'
    });
  }
});

// POST /api/bot/stop - Detener el bot de trading
router.post('/stop', async (req, res) => {
  try {
    const success = await tradingBot.stopBot();

    if (success) {
      res.json({
        success: true,
        message: 'Bot detenido correctamente',
        data: {
          status: 'stopped',
          timestamp: new Date().toISOString()
        }
      });
    } else {
      res.status(500).json({
        success: false,
        message: 'Error deteniendo el bot'
      });
    }

  } catch (error) {
    logger.error('Error deteniendo bot:', error);
    res.status(500).json({
      success: false,
      message: 'Error interno del servidor'
    });
  }
});

// GET /api/bot/status - Obtener estado del bot
router.get('/status', async (req, res) => {
  try {
    const status = await tradingBot.getStatus();

    res.json({
      success: true,
      data: {
        status: status,
        timestamp: new Date().toISOString()
      }
    });

  } catch (error) {
    logger.error('Error obteniendo estado del bot:', error);
    res.status(500).json({
      success: false,
      message: 'Error interno del servidor'
    });
  }
});

// GET /api/bot/config - Obtener configuración actual del bot
router.get('/config', async (req, res) => {
  try {
    const config = await tradingBot.getConfig();

    res.json({
      success: true,
      data: {
        config: config,
        timestamp: new Date().toISOString()
      }
    });

  } catch (error) {
    logger.error('Error obteniendo configuración del bot:', error);
    res.status(500).json({
      success: false,
      message: 'Error interno del servidor'
    });
  }
});

module.exports = { router };