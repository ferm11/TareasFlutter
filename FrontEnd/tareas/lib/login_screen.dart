import 'package:flutter/material.dart';
import 'colors.dart'; // Asegúrate de que tengas este archivo para los colores
import 'home_user_screen.dart'; // Asegúrate de importar la pantalla de bienvenida
import 'package:http/http.dart' as http; // Para realizar solicitudes HTTP
import 'dart:convert'; // Para convertir JSON

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();

  bool _isLoginSuccessful = false; // Indica si el login fue exitoso
  bool _showTokenInput = false; // Indica si se debe mostrar el campo para el token
  String _loginMessage = ''; // Mensaje de estado del login

  void _login() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _loginMessage = 'Por favor, ingresa un usuario y una contraseña';
      });
      return; // No hacer la solicitud si los campos están vacíos
    }

    try {
      // Realiza la solicitud al backend para iniciar sesión
      final response = await http.post(
        Uri.parse('http://localhost:3000/login'), // Cambia esto a tu URL de backend
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _isLoginSuccessful = true;
          _showTokenInput = true; // Muestra el campo para ingresar el token
          _loginMessage = 'Credenciales válidas, por favor ingresa el token'; // Mensaje de éxito
        });
      } else {
        // Manejar el error de inicio de sesión
        setState(() {
          _loginMessage = 'Credenciales inválidas'; // Mensaje de error
          _showTokenInput = false; // Asegúrate de ocultar el campo para el token
          _usernameController.clear(); // Limpiar el campo de usuario
          _passwordController.clear(); // Limpiar el campo de contraseña
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_loginMessage)),
        );
      }
    } catch (e) {
      setState(() {
        _loginMessage = 'Error al conectar con el servidor'; // Mensaje de error de conexión
        _usernameController.clear(); // Limpiar el campo de usuario
        _passwordController.clear(); // Limpiar el campo de contraseña
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_loginMessage)),
      );
      print(e); // Para depuración
    }
  }

  void _validateToken() async {
    final String token = _tokenController.text;
    final username = _usernameController.text; // Recuperar el nombre de usuario

    // Verifica si se está enviando el nombre de usuario
    if (username.isEmpty) {
      print('No se ingresó el nombre de usuario');
      return;
    }

    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, ingresa un token')),
      );
      return; // No hacer la solicitud si el token está vacío
    }

    try {
      // Realiza la solicitud al backend para validar el token
      final response = await http.post(
        Uri.parse('http://localhost:3000/validate_token'), // Cambia esto a tu URL de validación
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username, // Enviar el nombre de usuario
          'token': token}),
      );

      if (response.statusCode == 200) {
        // Si el token es válido, redirigir a la pantalla de bienvenida
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeUserScreen()),
        );
      } else {
        // Manejar el error de validación del token
        setState(() {
          _loginMessage = 'Token inválido'; // Mensaje de error
          _tokenController.clear(); // Limpiar el campo de token
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_loginMessage)),
        );
      }
    } catch (e) {
      setState(() {
        _loginMessage = 'Error al conectar con el servidor'; // Mensaje de error de conexión
        _tokenController.clear(); // Limpiar el campo de token
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_loginMessage)),
      );
      print(e); // Para depuración
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 171, 171, 245),
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32.0),
          decoration: BoxDecoration(
            color: Colors.white, // Cambiado a color lila
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 5,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Iniciar sesión',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentColor,
                ),
              ),
              SizedBox(height: 20),
              // Mostrar campos de usuario y contraseña solo si _isLoginSuccessful es falso
              if (!_isLoginSuccessful) ...[
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: 'Usuario',
                    prefixIcon: Icon(Icons.person, color: AppColors.primaryColor),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock, color: AppColors.primaryColor),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _login,
                  child: Text(
                    'Iniciar Sesión',
                    style: TextStyle(color: Colors.white), // Letras en blanco
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 100, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: Text(
                    '¿No tienes cuenta? Regístrate',
                    style: TextStyle(color: AppColors.primaryColor),
                  ),
                ),
              ] else ...[
                // Mostrar mensaje de éxito
                Text(
                  _loginMessage,
                  style: TextStyle(color: Colors.green, fontSize: 16),
                ),
              ],
              SizedBox(height: 20),
              // Mostrar el campo para el token solo si _showTokenInput es verdadero
              if (_showTokenInput) ...[
                TextField(
                  controller: _tokenController,
                  decoration: InputDecoration(
                    hintText: 'Ingresa tu token',
                    prefixIcon: Icon(Icons.vpn_key, color: AppColors.primaryColor),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _validateToken,
                  child: Text(
                    'Validar Token',
                    style: TextStyle(color: Colors.white), // Letras en blanco
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 100, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
