const binanceService = require('./binanceService');
const logger = require('../utils/logger');
const cron = require('node-cron');

class TradingBot {
  constructor() {
    this.isRunning = false;
    this.config = null;
    this.currentPosition = null;
    this.priceHistory = [];
    this.ema9 = [];
    this.ema21 = [];
    this.maxPrice = 0;
    this.entryPrice = 0;
    this.stopLoss = 0;
    this.trailingStopPrice = 0;
    this.logs = [];
    this.timer = null;
  }

  // Inicializar el bot
  async initialize() {
    logger.info('TradingBot inicializado');
  }

  // Iniciar el bot con configuración
  async startBot(config) {
    try {
      if (this.isRunning) {
        throw new Error('El bot ya está ejecutándose');
      }

      this.config = config;
      this.isRunning = true;
      
      // Configurar credenciales en el servicio de Binance
      binanceService.setCredentials(config.apiKey, config.secretKey);
      
      // Verificar credenciales
      const isValid = await binanceService.validateCredentials(config.apiKey, config.secretKey);
      if (!isValid) {
        throw new Error('Credenciales de Binance inválidas');
      }

      // Inicializar datos
      await this.initializeData();
      
      // Iniciar timer para análisis
      this.startAnalysisTimer();
      
      this.addLog('Bot iniciado correctamente', 'success');
      logger.info('TradingBot iniciado');
      
      return true;
    } catch (error) {
      this.addLog(`Error iniciando bot: ${error.message}`, 'error');
      logger.error('Error iniciando bot:', error);
      return false;
    }
  }

  // Detener el bot
  async stopBot() {
    try {
      this.isRunning = false;
      
      if (this.timer) {
        clearInterval(this.timer);
        this.timer = null;
      }

      this.addLog('Bot detenido', 'info');
      logger.info('TradingBot detenido');
      
      return true;
    } catch (error) {
      this.addLog(`Error deteniendo bot: ${error.message}`, 'error');
      logger.error('Error deteniendo bot:', error);
      return false;
    }
  }

  // Inicializar datos históricos
  async initializeData() {
    try {
      const symbol = this.config.selectedPair.replace('/', '');
      const klines = await binanceService.getKlines(symbol, '1m', 100);
      
      this.priceHistory = klines.map(k => k.close);
      this.calculateEMAs();
      
      this.addLog(`Datos históricos cargados para ${this.config.selectedPair}`, 'info');
    } catch (error) {
      this.addLog(`Error cargando datos históricos: ${error.message}`, 'error');
      throw error;
    }
  }

  // Calcular medias móviles exponenciales
  calculateEMAs() {
    const prices = this.priceHistory;
    this.ema9 = this.calculateEMA(prices, 9);
    this.ema21 = this.calculateEMA(prices, 21);
  }

  // Calcular EMA
  calculateEMA(prices, period) {
    const ema = [];
    const multiplier = 2 / (period + 1);
    
    // Primer valor es la media simple
    let sum = 0;
    for (let i = 0; i < period; i++) {
      sum += prices[i];
    }
    ema[period - 1] = sum / period;
    
    // Calcular EMA para el resto
    for (let i = period; i < prices.length; i++) {
      ema[i] = (prices[i] * multiplier) + (ema[i - 1] * (1 - multiplier));
    }
    
    return ema;
  }

  // Iniciar timer de análisis
  startAnalysisTimer() {
    this.timer = setInterval(async () => {
      if (this.isRunning) {
        await this.analyzeMarket();
      }
    }, 30000); // Analizar cada 30 segundos
  }

  // Analizar mercado y ejecutar estrategia
  async analyzeMarket() {
    try {
      const symbol = this.config.selectedPair.replace('/', '');
      const currentPrice = await binanceService.getCurrentPrice(symbol);
      
      // Actualizar historial de precios
      this.priceHistory.push(currentPrice);
      if (this.priceHistory.length > 100) {
        this.priceHistory.shift();
      }
      
      // Recalcular EMAs
      this.calculateEMAs();
      
      // Actualizar precio máximo
      if (currentPrice > this.maxPrice) {
        this.maxPrice = currentPrice;
      }
      
      // Verificar condiciones de trading
      await this.checkTradingConditions(currentPrice);
      
    } catch (error) {
      this.addLog(`Error en análisis de mercado: ${error.message}`, 'error');
      logger.error('Error en análisis de mercado:', error);
    }
  }

  // Verificar condiciones de trading
  async checkTradingConditions(currentPrice) {
    const latestEma9 = this.ema9[this.ema9.length - 1];
    const latestEma21 = this.ema21[this.ema21.length - 1];
    
    // Si no tenemos posición abierta
    if (!this.currentPosition) {
      // Verificar condición de compra
      if (this.shouldBuy(currentPrice, latestEma9, latestEma21)) {
        await this.executeBuyOrder(currentPrice);
      }
    } else {
      // Si tenemos posición abierta, verificar condiciones de venta
      if (this.shouldSell(currentPrice)) {
        await this.executeSellOrder(currentPrice);
      } else if (this.config.trailingStop) {
        // Actualizar trailing stop
        this.updateTrailingStop(currentPrice);
      }
    }
  }

  // Determinar si debe comprar
  shouldBuy(currentPrice, ema9, ema21) {
    // Verificar pullback desde el máximo
    const pullbackPercent = ((this.maxPrice - currentPrice) / this.maxPrice) * 100;
    
    if (pullbackPercent < this.config.pullbackPercent) {
      return false;
    }
    
    // Verificar EMA si está habilitado
    if (this.config.useEMA && ema9 <= ema21) {
      return false;
    }
    
    // Verificar tendencia alcista
    if (this.ema9.length >= 2 && this.ema21.length >= 2) {
      const prevEma9 = this.ema9[this.ema9.length - 2];
      const prevEma21 = this.ema21[this.ema21.length - 2];
      
      if (ema9 <= prevEma9 || ema21 <= prevEma21) {
        return false;
      }
    }
    
    return true;
  }

  // Determinar si debe vender
  shouldSell(currentPrice) {
    if (!this.currentPosition) return false;
    
    // Verificar take profit
    const profitPercent = ((currentPrice - this.entryPrice) / this.entryPrice) * 100;
    if (profitPercent >= this.config.profitTarget) {
      return true;
    }
    
    // Verificar stop loss
    if (currentPrice <= this.stopLoss) {
      return true;
    }
    
    // Verificar trailing stop
    if (this.config.trailingStop && currentPrice <= this.trailingStopPrice) {
      return true;
    }
    
    return false;
  }

  // Actualizar trailing stop
  updateTrailingStop(currentPrice) {
    if (currentPrice > this.entryPrice) {
      const newTrailingStop = currentPrice * (1 - this.config.trailingPercent / 100);
      if (newTrailingStop > this.trailingStopPrice) {
        this.trailingStopPrice = newTrailingStop;
        this.addLog(`Trailing stop actualizado a $${newTrailingStop.toFixed(2)}`, 'info');
      }
    }
  }

  // Ejecutar orden de compra
  async executeBuyOrder(price) {
    try {
      const symbol = this.config.selectedPair.replace('/', '');
      const balance = await binanceService.getAccountBalance();
      const quantity = (balance.available * 0.95) / price; // Usar 95% del balance
      
      const order = await binanceService.placeBuyOrder(symbol, quantity.toFixed(6));
      
      this.currentPosition = {
        symbol: symbol,
        quantity: quantity,
        entryPrice: price,
        timestamp: new Date()
      };
      
      this.entryPrice = price;
      this.stopLoss = price * 0.95; // Stop loss del 5%
      this.trailingStopPrice = price * (1 - this.config.trailingPercent / 100);
      
      this.addLog(`COMPRA ejecutada: ${quantity.toFixed(6)} ${symbol} a $${price.toFixed(2)}`, 'buy');
      
      // Enviar actualización por WebSocket
      global.broadcastToClients({
        type: 'trade',
        data: {
          action: 'buy',
          symbol: this.config.selectedPair,
          price: price,
          quantity: quantity,
          timestamp: new Date().toISOString()
        }
      });
      
    } catch (error) {
      this.addLog(`Error ejecutando compra: ${error.message}`, 'error');
      logger.error('Error ejecutando compra:', error);
    }
  }

  // Ejecutar orden de venta
  async executeSellOrder(price) {
    try {
      if (!this.currentPosition) return;
      
      const order = await binanceService.placeSellOrder(
        this.currentPosition.symbol, 
        this.currentPosition.quantity
      );
      
      const profit = ((price - this.entryPrice) / this.entryPrice) * 100;
      
      this.addLog(
        `VENTA ejecutada: ${this.currentPosition.quantity.toFixed(6)} ${this.currentPosition.symbol} a $${price.toFixed(2)} (${profit.toFixed(2)}% ganancia)`, 
        'sell'
      );
      
      // Enviar actualización por WebSocket
      global.broadcastToClients({
        type: 'trade',
        data: {
          action: 'sell',
          symbol: this.config.selectedPair,
          price: price,
          quantity: this.currentPosition.quantity,
          profit: profit,
          timestamp: new Date().toISOString()
        }
      });
      
      // Limpiar posición
      this.currentPosition = null;
      this.entryPrice = 0;
      this.stopLoss = 0;
      this.trailingStopPrice = 0;
      this.maxPrice = price; // Actualizar máximo para próxima operación
      
    } catch (error) {
      this.addLog(`Error ejecutando venta: ${error.message}`, 'error');
      logger.error('Error ejecutando venta:', error);
    }
  }

  // Agregar log
  addLog(message, type = 'info') {
    const log = {
      time: new Date().toLocaleTimeString(),
      message: message,
      type: type,
      timestamp: new Date().toISOString()
    };
    
    this.logs.push(log);
    
    // Mantener solo los últimos 100 logs
    if (this.logs.length > 100) {
      this.logs.shift();
    }
    
    // Enviar log por WebSocket
    global.broadcastToClients({
      type: 'log',
      data: log
    });
    
    logger.info(`[${type.toUpperCase()}] ${message}`);
  }

  // Obtener estado del bot
  getStatus() {
    return {
      isRunning: this.isRunning,
      config: this.config,
      currentPosition: this.currentPosition,
      maxPrice: this.maxPrice,
      entryPrice: this.entryPrice,
      stopLoss: this.stopLoss,
      trailingStopPrice: this.trailingStopPrice,
      logs: this.logs.slice(-10) // Últimos 10 logs
    };
  }

  // Obtener logs
  getLogs() {
    return this.logs;
  }
}

module.exports = new TradingBot();
