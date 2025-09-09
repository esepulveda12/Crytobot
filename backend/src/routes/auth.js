const express = require('express');
const binanceService = require('../services/binanceService');
const encryption = require('../utils/encryption');
const logger = require('../utils/logger');

const router = express.Router();

// Almacenamiento temporal de credenciales (en producción usar base de datos)
let userCredentials = null;

// POST /api/auth/login - Autenticar con Binance
router.post('/login', async (req, res) => {
  try {
    const { apiKey, secretKey } = req.body;

    if (!apiKey || !secretKey) {
      return res.status(400).json({
        success: false,
        message: 'API Key y Secret Key son requeridos'
      });
    }

    logger.info(`=== INICIO LOGIN ===`);
    logger.info(`API Key recibida: ${apiKey.substring(0, 10)}...`);
    logger.info(`Secret Key recibida: ${secretKey.substring(0, 10)}...`);

    // Validar credenciales con Binance directamente
    const isValid = await binanceService.validateCredentials(apiKey, secretKey);
    
    if (!isValid) {
      logger.error('Validación falló - credenciales inválidas');
      return res.status(401).json({
        success: false,
        message: 'Credenciales de Binance inválidas'
      });
    }

    // Encriptar y almacenar credenciales del usuario
    userCredentials = {
      apiKey: encryption.encrypt(apiKey),
      secretKey: encryption.encrypt(secretKey),
      timestamp: new Date().toISOString()
    };

    logger.info('Usuario autenticado correctamente');
    logger.info(`=== FIN LOGIN EXITOSO ===`);

    res.json({
      success: true,
      message: 'Autenticación exitosa',
      data: {
        authenticated: true,
        timestamp: new Date().toISOString()
      }
    });

  } catch (error) {
    logger.error('Error en autenticación:', error);
    res.status(500).json({
      success: false,
      message: 'Error interno del servidor'
    });
  }
});

// POST /api/auth/logout - Cerrar sesión
router.post('/logout', (req, res) => {
  try {
    userCredentials = null;
    logger.info('Usuario cerró sesión');

    res.json({
      success: true,
      message: 'Sesión cerrada correctamente'
    });

  } catch (error) {
    logger.error('Error cerrando sesión:', error);
    res.status(500).json({
      success: false,
      message: 'Error interno del servidor'
    });
  }
});

// GET /api/auth/status - Verificar estado de autenticación
router.get('/status', (req, res) => {
  try {
    const isAuthenticated = userCredentials !== null;

    res.json({
      success: true,
      data: {
        authenticated: isAuthenticated,
        timestamp: new Date().toISOString()
      }
    });

  } catch (error) {
    logger.error('Error verificando estado:', error);
    res.status(500).json({
      success: false,
      message: 'Error interno del servidor'
    });
  }
});

// Función helper para obtener credenciales desencriptadas
function getDecryptedCredentials() {
  if (!userCredentials) {
    throw new Error('Usuario no autenticado');
  }

  return {
    apiKey: encryption.decrypt(userCredentials.apiKey),
    secretKey: encryption.decrypt(userCredentials.secretKey)
  };
}

// Middleware para verificar autenticación
function requireAuth(req, res, next) {
  if (!userCredentials) {
    return res.status(401).json({
      success: false,
      message: 'Usuario no autenticado'
    });
  }
  next();
}

module.exports = { router, getDecryptedCredentials, requireAuth };
