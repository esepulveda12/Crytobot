const express = require('express');
const tradingBot = require('../services/tradingBot');
const { getDecryptedCredentials, requireAuth } = require('./auth');
const logger = require('../utils/logger');

const router = express.Router();

// POST /api/bot/start - Iniciar el bot de trading
router.post('/start', requireAuth, async (req, res) => {
  try {
    const { selectedPair, pullbackPercent, profitTarget, useEMA, trailingStop, trailingPercent } = req.body;

    // Validar parámetros requeridos
    if (!selectedPair || !pullbackPercent || !profitTarget) {
      return res.status(400).json({
        success: false,
        message: 'Parámetros requeridos: selectedPair, pullbackPercent, profitTarget'
      });
    }

    const credentials = getDecryptedCredentials();
    
    const config = {
      selectedPair,
      pullbackPercent: parseFloat(pullbackPercent),
      profitTarget: parseFloat(profitTarget),
      useEMA: useEMA || false,
      trailingStop: trailingStop || false,
      trailingPercent: parseFloat(trailingPercent) || 2.0,
      apiKey: credentials.apiKey,
      secretKey: credentials.secretKey
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
router.post('/stop', requireAuth, async (req, res) => {
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
router.get('/status', requireAuth, async (req, res) => {
  try {
    const status = tradingBot.getStatus();

    res.json({
      success: true,
      data: status
    });

  } catch (error) {
    logger.error('Error obteniendo estado del bot:', error);
    res.status(500).json({
      success: false,
      message: 'Error obteniendo estado del bot'
    });
  }
});

// GET /api/bot/logs - Obtener logs del bot
router.get('/logs', requireAuth, async (req, res) => {
  try {
    const logs = tradingBot.getLogs();

    res.json({
      success: true,
      data: {
        logs: logs,
        count: logs.length,
        timestamp: new Date().toISOString()
      }
    });

  } catch (error) {
    logger.error('Error obteniendo logs:', error);
    res.status(500).json({
      success: false,
      message: 'Error obteniendo logs del bot'
    });
  }
});

// PUT /api/bot/config - Actualizar configuración del bot
router.put('/config', requireAuth, async (req, res) => {
  try {
    const { selectedPair, pullbackPercent, profitTarget, useEMA, trailingStop, trailingPercent } = req.body;

    if (!selectedPair || !pullbackPercent || !profitTarget) {
      return res.status(400).json({
        success: false,
        message: 'Parámetros requeridos: selectedPair, pullbackPercent, profitTarget'
      });
    }

    const credentials = getDecryptedCredentials();
    
    const config = {
      selectedPair,
      pullbackPercent: parseFloat(pullbackPercent),
      profitTarget: parseFloat(profitTarget),
      useEMA: useEMA || false,
      trailingStop: trailingStop || false,
      trailingPercent: parseFloat(trailingPercent) || 2.0,
      apiKey: credentials.apiKey,
      secretKey: credentials.secretKey
    };

    // Si el bot está corriendo, reiniciarlo con la nueva configuración
    if (tradingBot.isRunning) {
      await tradingBot.stopBot();
      const success = await tradingBot.startBot(config);
      
      if (success) {
        res.json({
          success: true,
          message: 'Configuración actualizada y bot reiniciado',
          data: {
            config: config,
            status: 'running',
            timestamp: new Date().toISOString()
          }
        });
      } else {
        res.status(500).json({
          success: false,
          message: 'Error actualizando configuración'
        });
      }
    } else {
      res.json({
        success: true,
        message: 'Configuración actualizada',
        data: {
          config: config,
          status: 'stopped',
          timestamp: new Date().toISOString()
        }
      });
    }

  } catch (error) {
    logger.error('Error actualizando configuración:', error);
    res.status(500).json({
      success: false,
      message: 'Error interno del servidor'
    });
  }
});

// GET /api/bot/analytics - Obtener datos analíticos del bot
router.get('/analytics', requireAuth, async (req, res) => {
  try {
    const status = tradingBot.getStatus();
    const logs = tradingBot.getLogs();

    // Calcular estadísticas básicas
    const buyLogs = logs.filter(log => log.type === 'buy');
    const sellLogs = logs.filter(log => log.type === 'sell');
    const errorLogs = logs.filter(log => log.type === 'error');

    const analytics = {
      totalTrades: buyLogs.length,
      completedTrades: sellLogs.length,
      openPositions: status.currentPosition ? 1 : 0,
      errors: errorLogs.length,
      uptime: status.isRunning ? 'running' : 'stopped',
      currentPrice: status.maxPrice || 0,
      entryPrice: status.entryPrice || 0,
      stopLoss: status.stopLoss || 0,
      trailingStop: status.trailingStopPrice || 0
    };

    res.json({
      success: true,
      data: analytics
    });

  } catch (error) {
    logger.error('Error obteniendo analytics:', error);
    res.status(500).json({
      success: false,
      message: 'Error obteniendo datos analíticos'
    });
  }
});

module.exports = router;
