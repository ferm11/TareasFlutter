import 'package:flutter/material.dart';
import 'colors.dart'; // Asegúrate de que tengas este archivo para los colores
import 'home_user_screen.dart'; // Asegúrate de importar la pantalla de bienvenida
import 'package:http/http.dart' as http; // Para realizar solicitudes HTTP
import 'dart:convert'; // Para convertir JSON
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Para verificar la conexión a internet
import 'package:url_launcher/url_launcher.dart'; // Para abrir URLs

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();

  bool _isLoginSuccessful = false;
  bool _showTokenInput = false;
  String _loginMessage = '';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  void _login() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        AwesomeDialog(
        context: context,
        dialogType: DialogType.info,
        animType: AnimType.bottomSlide,
        title: 'Alerta',
        desc: 'Por favor ingresa el username y el password.',
        btnOkText: 'Cerrar',
        btnOkOnPress: () {

        },
      ).show();
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
          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.bottomSlide,
            title: 'Exito!',
            desc: 'Credenciales válidas. \n Por favor ingresa el token que se proporciono a tu correo.',
            btnOkText: 'Cerrar',
            btnOkOnPress: () {

            },
          ).show();
          _isLoginSuccessful = true;
          _showTokenInput = true; // Muestra el campo para ingresar el token
        });
      } else {
        // Manejar el error de inicio de sesión
        setState(() {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.bottomSlide,
            title: 'Ojo!',
            desc: 'Username o password inválidos.',
            btnOkText: 'Cerrar',
            btnOkOnPress: () {

            },
          ).show();
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

    if (token.isEmpty) {
      AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.bottomSlide,
            title: 'Alerta!',
            desc: 'Por favor ingresa un token.',
            btnOkText: 'Cerrar',
            btnOkOnPress: () {

            },
          ).show();
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
        AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.bottomSlide,
            title: 'Exito!',
            desc: 'Token válido. \n Bienvenido $username',
            btnOkText: 'Cerrar',
            btnOkOnPress: () {
              Navigator.pushNamed(context, '/home_user_screen');
            },
          ).show();
      } else {
        // Manejar el error de validación del token
        setState(() {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.bottomSlide,
            title: 'Token invalido.',
            desc: '',
            btnOkText: 'Cerrar',
            btnOkOnPress: () {
            },
          ).show();
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

  Future<void> _signInWithGoogle(BuildContext context) async {
  const String auth0Domain = 'dev-mbxq2mv4zudqw8f4.us.auth0.com'; // Tu dominio Auth0
  const String clientId = 'FOnFMDdBgQeyK59ydo76MBGBBtw2hFcT'; // Tu Client ID

  try {
    // Inicia sesión con Google
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      return; // El usuario canceló el inicio de sesión
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final String email = googleUser.email;

    // Envía el email al backend para verificar si está registrado
    final response = await http.post(
      Uri.parse('http://localhost:3000/google-login'), // Cambia esto a tu ruta de backend
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );

    if (response.statusCode == 200) {
      // Si el correo está registrado, mostrar el diálogo de bienvenida
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.bottomSlide,
        title: '¡Bienvenido!',
        desc: 'Hola ${googleUser.displayName},\n¡Bienvenido de nuevo!',
        btnOkText: 'Continuar',
        btnOkOnPress: () {
          // Redirigir al usuario a la pantalla de HomeUserScreen
          Navigator.pushNamed(context, '/home_user_screen');
        },
      ).show();
    } else if (response.statusCode == 404) {
      // Si el correo no está registrado, mostrar el mensaje de error
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.bottomSlide,
        title: 'Error',
        desc: 'El correo ${googleUser.email} no está registrado.',
        btnOkText: 'Cerrar',
        btnOkOnPress: () {
          Navigator.pushNamed(context, '/home');
        },
      ).show();
    } else {
      // Si ocurre otro error, manejarlo aquí
      throw Exception('Error en la autenticación con Google');
    }
  } catch (e) {
    print('Error en el inicio de sesión: $e');
    // Muestra un mensaje de error o toma alguna acción
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
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Iniciar sesión',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentColor,
                ),
              ),
              const SizedBox(height: 20),
              if (!_isLoginSuccessful) ...[
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: 'Usuario',
                    prefixIcon: const Icon(Icons.person, color: AppColors.primaryColor),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock, color: AppColors.primaryColor),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Iniciar Sesión',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    _signInWithGoogle(context);
                  },
                  icon: const Icon(Icons.login),
                  label: const Text('Ingresar con Google'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: const Text(
                          '¿No tienes cuenta? Regístrate',
                          style: TextStyle(color: Colors.blue),
                        ),
                        ),
              ],
              if (_showTokenInput) ...[
                const SizedBox(height: 20),
                TextField(
                  controller: _tokenController,
                  decoration: InputDecoration(
                    hintText: 'Token',
                    prefixIcon: const Icon(Icons.security, color: AppColors.primaryColor),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _validateToken,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Validar Token',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Text(
                _loginMessage,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
