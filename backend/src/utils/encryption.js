const CryptoJS = require('crypto-js');

class EncryptionService {
  constructor() {
    this.secretKey = process.env.ENCRYPTION_KEY || 'default_key_32_characters_long_123';
    
    // Asegurar que la clave tenga exactamente 32 caracteres
    if (this.secretKey.length !== 32) {
      this.secretKey = this.secretKey.padEnd(32, '0').substring(0, 32);
    }
  }

  // Encriptar datos sensibles
  encrypt(text) {
    try {
      const encrypted = CryptoJS.AES.encrypt(text, this.secretKey).toString();
      return encrypted;
    } catch (error) {
      throw new Error('Error encriptando datos: ' + error.message);
    }
  }

  // Desencriptar datos
  decrypt(encryptedText) {
    try {
      const decrypted = CryptoJS.AES.decrypt(encryptedText, this.secretKey);
      return decrypted.toString(CryptoJS.enc.Utf8);
    } catch (error) {
      throw new Error('Error desencriptando datos: ' + error.message);
    }
  }

  // Generar hash para verificación
  hash(text) {
    return CryptoJS.SHA256(text).toString();
  }

  // Verificar hash
  verifyHash(text, hash) {
    return this.hash(text) === hash;
  }
}

module.exports = new EncryptionService();
