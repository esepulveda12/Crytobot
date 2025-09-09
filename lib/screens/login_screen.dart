import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/user_credentials.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  final Function(bool) onLoginSuccess;

  const LoginScreen({
    super.key,
    required this.onLoginSuccess,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController();
  final _secretKeyController = TextEditingController();
  bool _showSecretKey = false;
  bool _isConnecting = false;
  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    _apiKeyController.dispose();
    _secretKeyController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isConnecting = true;
    });

    try {
      final credentials = UserCredentials(
        apiKey: _apiKeyController.text.trim(),
        secretKey: _secretKeyController.text.trim(),
      );

      final success = await _apiService.authenticate(credentials);
      
      if (success) {
        widget.onLoginSuccess(true);
      } else {
        _showErrorSnackBar('Error de autenticación. Verifica tus credenciales.');
      }
    } catch (e) {
      _showErrorSnackBar('Error de conexión: $e');
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1f2937),
              Color(0xFF111827),
              Color(0xFF000000),
            ],
          ),
        ),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF1f2937).withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF374151)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo and title
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFfbbf24), Color(0xFFf59e0b)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.trending_up,
                      color: Colors.black,
                      size: 32,
                    ),
                  ).animate().scale(duration: 600.ms),
                  
                  const SizedBox(height: 16),
                  
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFfbbf24), Color(0xFFf59e0b)],
                    ).createShader(bounds),
                    child: const Text(
                      'CryptoBot Spot',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  
                  const SizedBox(height: 8),
                  
                  const Text(
                    'Conecta tu cuenta de Binance',
                    style: TextStyle(
                      color: Color(0xFF9ca3af),
                      fontSize: 16,
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                  
                  const SizedBox(height: 32),
                  
                  // API Key input
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'API Key',
                        style: TextStyle(
                          color: Color(0xFFd1d5db),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _apiKeyController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu API Key';
                          }
                          return null;
                        },
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Ingresa tu API Key de Binance',
                          hintStyle: const TextStyle(color: Color(0xFF9ca3af)),
                          filled: true,
                          fillColor: const Color(0xFF374151).withOpacity(0.5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF4b5563)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFfbbf24), width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ).animate().slideX(delay: 600.ms),
                  
                  const SizedBox(height: 24),
                  
                  // Secret Key input
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Secret Key',
                        style: TextStyle(
                          color: Color(0xFFd1d5db),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _secretKeyController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu Secret Key';
                          }
                          return null;
                        },
                        obscureText: !_showSecretKey,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Ingresa tu Secret Key',
                          hintStyle: const TextStyle(color: Color(0xFF9ca3af)),
                          filled: true,
                          fillColor: const Color(0xFF374151).withOpacity(0.5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF4b5563)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFfbbf24), width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showSecretKey ? Icons.visibility_off : Icons.visibility,
                              color: const Color(0xFF9ca3af),
                            ),
                            onPressed: () => setState(() => _showSecretKey = !_showSecretKey),
                          ),
                        ),
                      ),
                    ],
                  ).animate().slideX(delay: 800.ms),
                  
                  const SizedBox(height: 32),
                  
                  // Login button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isConnecting ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFfbbf24),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: _isConnecting
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text('Conectando...'),
                              ],
                            )
                          : const Text(
                              'Guardar y Conectar',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ).animate().slideY(delay: 1000.ms),
                  
                  const SizedBox(height: 24),
                  
                  // Security info
                  Column(
                    children: [
                      const Text(
                        '🔒 Tus claves se almacenan de forma segura y encriptada',
                        style: TextStyle(
                          color: Color(0xFF6b7280),
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Solo trading Spot - Sin Futuros',
                        style: TextStyle(
                          color: Color(0xFF6b7280),
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ).animate().fadeIn(delay: 1200.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
