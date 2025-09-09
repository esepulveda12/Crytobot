const express = require('express');
const binanceService = require('../services/binanceService');
const { getDecryptedCredentials, requireAuth } = require('./auth');
const logger = require('../utils/logger');

const router = express.Router();

// GET /api/trades/history - Obtener historial de trades
router.get('/history', requireAuth, async (req, res) => {
  try {
    const { symbol = 'BTCUSDT', limit = 50 } = req.query;
    const credentials = getDecryptedCredentials();
    
    binanceService.setCredentials(credentials.apiKey, credentials.secretKey);
    const orders = await binanceService.getOrderHistory(symbol, parseInt(limit));

    // Procesar órdenes para el formato de la app
    const trades = orders
      .filter(order => order.status === 'FILLED')
      .map(order => ({
        pair: order.symbol.replace('USDT', '/USDT'),
        type: order.side.toLowerCase(),
        price: parseFloat(order.price),
        amount: parseFloat(order.executedQty),
        time: new Date(order.time).toLocaleString(),
        profit: order.side === 'SELL' ? calculateProfit(order) : null,
        orderId: order.orderId,
        status: order.status
      }))
      .sort((a, b) => new Date(b.time) - new Date(a.time));

    res.json({
      success: true,
      data: {
        trades: trades,
        count: trades.length,
        symbol: symbol,
        timestamp: new Date().toISOString()
      }
    });

  } catch (error) {
    logger.error('Error obteniendo historial de trades:', error);
    res.status(500).json({
      success: false,
      message: 'Error obteniendo historial de trades'
    });
  }
});

// GET /api/trades/current - Obtener posición actual
router.get('/current', requireAuth, async (req, res) => {
  try {
    const tradingBot = require('../services/tradingBot');
    const status = tradingBot.getStatus();

    if (status.currentPosition) {
      const currentPrice = await binanceService.getCurrentPrice(status.currentPosition.symbol);
      const profit = ((currentPrice - status.entryPrice) / status.entryPrice) * 100;

      res.json({
        success: true,
        data: {
          hasPosition: true,
          position: {
            symbol: status.currentPosition.symbol.replace('USDT', '/USDT'),
            quantity: status.currentPosition.quantity,
            entryPrice: status.entryPrice,
            currentPrice: currentPrice,
            profit: profit,
            stopLoss: status.stopLoss,
            trailingStop: status.trailingStopPrice,
            timestamp: status.currentPosition.timestamp
          }
        }
      });
    } else {
      res.json({
        success: true,
        data: {
          hasPosition: false,
          position: null
        }
      });
    }

  } catch (error) {
    logger.error('Error obteniendo posición actual:', error);
    res.status(500).json({
      success: false,
      message: 'Error obteniendo posición actual'
    });
  }
});

// GET /api/trades/performance - Obtener rendimiento del bot
router.get('/performance', requireAuth, async (req, res) => {
  try {
    const { symbol = 'BTCUSDT', days = 7 } = req.query;
    const credentials = getDecryptedCredentials();
    
    binanceService.setCredentials(credentials.apiKey, credentials.secretKey);
    const orders = await binanceService.getOrderHistory(symbol, 100);

    // Filtrar órdenes de los últimos N días
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - parseInt(days));
    
    const recentOrders = orders.filter(order => 
      new Date(order.time) >= cutoffDate && order.status === 'FILLED'
    );

    // Calcular métricas de rendimiento
    const buyOrders = recentOrders.filter(order => order.side === 'BUY');
    const sellOrders = recentOrders.filter(order => order.side === 'SELL');
    
    let totalProfit = 0;
    let totalTrades = 0;
    let winningTrades = 0;
    let losingTrades = 0;

    // Calcular ganancias por trade
    for (let i = 0; i < sellOrders.length; i++) {
      const sellOrder = sellOrders[i];
      const buyOrder = buyOrders.find(buy => 
        new Date(buy.time) < new Date(sellOrder.time) && 
        !buy.processed
      );
      
      if (buyOrder) {
        buyOrder.processed = true;
        const profit = (parseFloat(sellOrder.price) - parseFloat(buyOrder.price)) * parseFloat(sellOrder.executedQty);
        totalProfit += profit;
        totalTrades++;
        
        if (profit > 0) {
          winningTrades++;
        } else {
          losingTrades++;
        }
      }
    }

    const winRate = totalTrades > 0 ? (winningTrades / totalTrades) * 100 : 0;
    const avgProfit = totalTrades > 0 ? totalProfit / totalTrades : 0;

    res.json({
      success: true,
      data: {
        period: `${days} días`,
        totalTrades: totalTrades,
        winningTrades: winningTrades,
        losingTrades: losingTrades,
        winRate: winRate,
        totalProfit: totalProfit,
        avgProfit: avgProfit,
        symbol: symbol,
        timestamp: new Date().toISOString()
      }
    });

  } catch (error) {
    logger.error('Error obteniendo rendimiento:', error);
    res.status(500).json({
      success: false,
      message: 'Error obteniendo datos de rendimiento'
    });
  }
});

// Función helper para calcular ganancia
function calculateProfit(order) {
  // Esta es una implementación simplificada
  // En una implementación real, necesitarías rastrear el precio de compra
  return null;
}

module.exports = router;
