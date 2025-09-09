import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_credentials.dart';
import '../models/bot_config.dart';
import '../models/log_entry.dart';
import '../models/trade_history.dart';

class ApiService {
  static const String baseUrl = 'https://cryptobot-spot-backend.onrender.com/api'; // URL del backend en Render
  static const Duration timeout = Duration(seconds: 30);
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Headers comunes
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Autenticación
  Future<bool> authenticate(UserCredentials credentials) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers,
        body: jsonEncode(credentials.toJson()),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        // Guardar credenciales de forma segura
        await _storage.write(key: 'api_key', value: credentials.apiKey);
        await _storage.write(key: 'secret_key', value: credentials.secretKey);
        return true;
      }
      return false;
    } catch (e) {
      print('Error en autenticación: $e');
      return false;
    }
  }

  // Verificar si el usuario está autenticado
  Future<bool> isAuthenticated() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/status'),
        headers: _headers,
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['authenticated'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error verificando autenticación: $e');
      return false;
    }
  }

  // Cerrar sesión
  Future<bool> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: _headers,
      ).timeout(timeout);

      if (response.statusCode == 200) {
        // Limpiar credenciales almacenadas
        await _storage.delete(key: 'api_key');
        await _storage.delete(key: 'secret_key');
        return true;
      }
      return false;
    } catch (e) {
      print('Error cerrando sesión: $e');
      return false;
    }
  }

  // Obtener balance
  Future<double> getBalance() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/account/balance'),
        headers: _headers,
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['data']['balance'] ?? 0.0).toDouble();
      }
      return 0.0;
    } catch (e) {
      print('Error obteniendo balance: $e');
      return 0.0;
    }
  }

  // Iniciar bot
  Future<bool> startBot(BotConfig config) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/bot/start'),
        headers: _headers,
        body: jsonEncode(config.toJson()),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error iniciando bot: $e');
      return false;
    }
  }

  // Detener bot
  Future<bool> stopBot() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/bot/stop'),
        headers: _headers,
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error deteniendo bot: $e');
      return false;
    }
  }

  // Obtener logs
  Future<List<LogEntry>> getLogs() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/bot/logs'),
        headers: _headers,
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> logsJson = data['data']['logs'] ?? [];
        return logsJson.map((json) => LogEntry.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error obteniendo logs: $e');
      return [];
    }
  }

  // Obtener historial de trades
  Future<List<TradeHistory>> getTradeHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/trades/history'),
        headers: _headers,
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> tradesJson = data['data']['trades'] ?? [];
        return tradesJson.map((json) => TradeHistory.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error obteniendo historial: $e');
      return [];
    }
  }

  // Obtener estado del bot
  Future<Map<String, dynamic>> getBotStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/bot/status'),
        headers: _headers,
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? {};
      }
      return {};
    } catch (e) {
      print('Error obteniendo estado del bot: $e');
      return {};
    }
  }

  // Actualizar configuración del bot
  Future<bool> updateBotConfig(BotConfig config) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/bot/config'),
        headers: _headers,
        body: jsonEncode(config.toJson()),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error actualizando configuración: $e');
      return false;
    }
  }

  // Obtener precio actual de un símbolo
  Future<double> getCurrentPrice(String symbol) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/account/price/$symbol'),
        headers: _headers,
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['data']['price'] ?? 0.0).toDouble();
      }
      return 0.0;
    } catch (e) {
      print('Error obteniendo precio: $e');
      return 0.0;
    }
  }

  // Obtener lista de símbolos disponibles
  Future<List<Map<String, String>>> getAvailableSymbols() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/account/symbols'),
        headers: _headers,
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> symbolsJson = data['data']['symbols'] ?? [];
        return symbolsJson.map((json) => {
          'symbol': (json['symbol'] ?? '').toString(),
          'name': (json['name'] ?? '').toString(),
          'base': (json['base'] ?? '').toString(),
          'quote': (json['quote'] ?? '').toString(),
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error obteniendo símbolos: $e');
      return [];
    }
  }
}
