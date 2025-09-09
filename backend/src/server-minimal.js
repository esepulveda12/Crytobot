const express = require('express');
const app = express();

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString()
  });
});

// Ruta básica
app.get('/', (req, res) => {
  res.json({ 
    message: 'CryptoBot Spot Backend is running!',
    timestamp: new Date().toISOString()
  });
});

// Iniciar servidor
const PORT = process.env.PORT || 10000;
app.listen(PORT, () => {
  console.log(`Servidor iniciado en puerto ${PORT}`);
});

module.exports = app;
