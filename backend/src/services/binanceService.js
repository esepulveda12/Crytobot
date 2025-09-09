const axios = require('axios');
const crypto = require('crypto');
const logger = require('../utils/logger');
const encryption = require('../utils/encryption');

class BinanceService {
  constructor() {
    this.baseURL = process.env.BINANCE_BASE_URL || 'https://testnet.binance.vision';
    this.wsURL = process.env.BINANCE_WS_URL || 'wss://testnet.binance.vision/ws';
    this.userCredentials = null;
    this.isInitialized = false;
  }

  // Inicializar el servicio
  async initialize() {
    this.isInitialized = true;
    logger.info('BinanceService inicializado');
  }

  // Configurar credenciales del usuario
  setCredentials(apiKey, secretKey) {
    this.userCredentials = {
      apiKey: apiKey,
      secretKey: secretKey
    };
    logger.info('Credenciales de Binance configuradas');
  }

  // Generar firma para autenticación
  generateSignature(queryString, secretKey = null) {
    const keyToUse = secretKey || (this.userCredentials ? this.userCredentials.secretKey : null);
    if (!keyToUse) {
      throw new Error('Secret Key no proporcionada');
    }
    return crypto
      .createHmac('sha256', keyToUse)
      .update(queryString)
      .digest('hex');
  }

  // Crear headers para requests autenticados
  createAuthHeaders() {
    if (!this.userCredentials) {
      throw new Error('Credenciales no configuradas');
    }
    return {
      'X-MBX-APIKEY': this.userCredentials.apiKey
    };
  }

  // Verificar conexión con Binance
  async testConnection() {
    try {
      const response = await axios.get(`${this.baseURL}/api/v3/ping`);
      return response.status === 200;
    } catch (error) {
      logger.error('Error verificando conexión con Binance:', error.message);
      return false;
    }
  }

  // Verificar credenciales de API
  async validateCredentials(apiKey, secretKey) {
    try {
      logger.info(`=== INICIO VALIDACIÓN ===`);
      logger.info(`API Key: ${apiKey.substring(0, 10)}...`);
      logger.info(`Secret Key: ${secretKey.substring(0, 10)}...`);
      logger.info(`Base URL: ${this.baseURL}`);
      
      // Usar timestamp en milisegundos como lo hace Binance
      const timestamp = Date.now();
      const queryString = `timestamp=${timestamp}`;
      
      // Generar signature usando la secretKey directamente
      const signature = this.generateSignature(queryString, secretKey);
      
      logger.info(`Timestamp: ${timestamp}`);
      logger.info(`Query String: ${queryString}`);
      logger.info(`Signature: ${signature.substring(0, 20)}...`);
      
      // Headers correctos para Binance
      const headers = {
        'X-MBX-APIKEY': apiKey
      };
      
      // URL completa con query string y signature
      const url = `${this.baseURL}/api/v3/account?${queryString}&signature=${signature}`;
      
      logger.info(`URL completa: ${url}`);
      logger.info(`Headers: ${JSON.stringify(headers)}`);
      
      // Usar endpoint que requiera autenticación para validar credenciales
      const response = await axios.get(url, { headers });

      logger.info('Credenciales validadas correctamente');
      logger.info(`=== FIN VALIDACIÓN EXITOSA ===`);
      
      // Configurar credenciales solo si la validación fue exitosa
      this.setCredentials(apiKey, secretKey);
      
      return response.status === 200;
    } catch (error) {
      logger.error(`=== ERROR EN VALIDACIÓN ===`);
      logger.error('Error validando credenciales:', error.response?.data || error.message);
      logger.error('Status:', error.response?.status);
      logger.error('Headers de respuesta:', error.response?.headers);
      logger.error('Error completo:', error);
      logger.error(`=== FIN ERROR ===`);
      return false;
    }
  }

  // Obtener balance de la cuenta
  async getAccountBalance() {
    try {
      if (!this.userCredentials) {
        throw new Error('Credenciales no configuradas');
      }

      const timestamp = Date.now();
      const queryString = `timestamp=${timestamp}`;
      const signature = this.generateSignature(queryString);

      const response = await axios.get(
        `${this.baseURL}/api/v3/account?${queryString}&signature=${signature}`,
        { headers: this.createAuthHeaders() }
      );

      const balances = response.data.balances;
      const usdtBalance = balances.find(balance => balance.asset === 'USDT');
      
      return {
        total: parseFloat(usdtBalance?.free || 0),
        available: parseFloat(usdtBalance?.free || 0),
        locked: parseFloat(usdtBalance?.locked || 0)
      };
    } catch (error) {
      logger.error('Error obteniendo balance:', error.message);
      throw error;
    }
  }

  // Obtener precio actual de un par
  async getCurrentPrice(symbol) {
    try {
      const response = await axios.get(`${this.baseURL}/api/v3/ticker/price?symbol=${symbol}`);
      return parseFloat(response.data.price);
    } catch (error) {
      logger.error(`Error obteniendo precio de ${symbol}:`, error.message);
      throw error;
    }
  }

  // Obtener datos de klines (velas) para análisis técnico
  async getKlines(symbol, interval = '1m', limit = 100) {
    try {
      const response = await axios.get(
        `${this.baseURL}/api/v3/klines?symbol=${symbol}&interval=${interval}&limit=${limit}`
      );
      
      return response.data.map(kline => ({
        openTime: kline[0],
        open: parseFloat(kline[1]),
        high: parseFloat(kline[2]),
        low: parseFloat(kline[3]),
        close: parseFloat(kline[4]),
        volume: parseFloat(kline[5]),
        closeTime: kline[6]
      }));
    } catch (error) {
      logger.error(`Error obteniendo klines de ${symbol}:`, error.message);
      throw error;
    }
  }

  // Realizar orden de compra
  async placeBuyOrder(symbol, quantity) {
    try {
      if (!this.userCredentials) {
        throw new Error('Credenciales no configuradas');
      }

      const timestamp = Date.now();
      const queryString = `symbol=${symbol}&side=BUY&type=MARKET&quantity=${quantity}&timestamp=${timestamp}`;
      const signature = this.generateSignature(queryString);

      const response = await axios.post(
        `${this.baseURL}/api/v3/order?${queryString}&signature=${signature}`,
        {},
        { headers: this.createAuthHeaders() }
      );

      return response.data;
    } catch (error) {
      logger.error('Error realizando orden de compra:', error.message);
      throw error;
    }
  }

  // Realizar orden de venta
  async placeSellOrder(symbol, quantity) {
    try {
      if (!this.userCredentials) {
        throw new Error('Credenciales no configuradas');
      }

      const timestamp = Date.now();
      const queryString = `symbol=${symbol}&side=SELL&type=MARKET&quantity=${quantity}&timestamp=${timestamp}`;
      const signature = this.generateSignature(queryString);

      const response = await axios.post(
        `${this.baseURL}/api/v3/order?${queryString}&signature=${signature}`,
        {},
        { headers: this.createAuthHeaders() }
      );

      return response.data;
    } catch (error) {
      logger.error('Error realizando orden de venta:', error.message);
      throw error;
    }
  }

  // Obtener historial de órdenes
  async getOrderHistory(symbol, limit = 50) {
    try {
      if (!this.userCredentials) {
        throw new Error('Credenciales no configuradas');
      }

      const timestamp = Date.now();
      const queryString = `symbol=${symbol}&limit=${limit}&timestamp=${timestamp}`;
      const signature = this.generateSignature(queryString);

      const response = await axios.get(
        `${this.baseURL}/api/v3/allOrders?${queryString}&signature=${signature}`,
        { headers: this.createAuthHeaders() }
      );

      return response.data;
    } catch (error) {
      logger.error('Error obteniendo historial de órdenes:', error.message);
      throw error;
    }
  }

  // Obtener información del par
  async getSymbolInfo(symbol) {
    try {
      const response = await axios.get(`${this.baseURL}/api/v3/exchangeInfo`);
      const symbolInfo = response.data.symbols.find(s => s.symbol === symbol);
      
      if (!symbolInfo) {
        throw new Error(`Par ${symbol} no encontrado`);
      }

      return {
        symbol: symbolInfo.symbol,
        baseAsset: symbolInfo.baseAsset,
        quoteAsset: symbolInfo.quoteAsset,
        status: symbolInfo.status,
        filters: symbolInfo.filters
      };
    } catch (error) {
      logger.error(`Error obteniendo información de ${symbol}:`, error.message);
      throw error;
    }
  }
}

module.exports = new BinanceService();
