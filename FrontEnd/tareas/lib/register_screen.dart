import 'package:flutter/material.dart';
import 'colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart'; // Para FilteringTextInputFormatter
import 'package:awesome_dialog/awesome_dialog.dart';

class RegisterScreen extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  RegisterScreen({super.key});

  bool validateEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  bool validatePhoneNumber(String phone) {
    return RegExp(r'^[0-9]+$').hasMatch(phone) && phone.length >= 10;
  }

  bool validatePassword(String password) {
    return password.length >= 8 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[0-9]')) &&
        password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
  }

  Future<void> registerUser(BuildContext context) async {
    final String username = _usernameController.text.trim();
    final String nombre = _nombreController.text.trim();
    final String apellidos = _apellidosController.text.trim();
    final String telefono = _telefonoController.text.trim();
    final String correo = _correoController.text.trim();
    final int? edad = int.tryParse(_edadController.text.trim());
    final String password = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    // Validaciones
    if (username.isEmpty || nombre.isEmpty || apellidos.isEmpty || telefono.isEmpty || correo.isEmpty || edad == null || password.isEmpty) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.info,
        animType: AnimType.bottomSlide,
        title: 'Alerta',
        desc: 'Por favor completa todos los campos.',
        btnOkText: 'Cerrar',
        btnOkOnPress: () {

        },
      ).show();
      return;
    }

    if (!validateEmail(correo)) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.info,
        animType: AnimType.bottomSlide,
        title: 'Alerta',
        desc: 'Por favor introduce un correo electrónico válido.',
        btnOkText: 'Cerrar',
        btnOkOnPress: () {

        },
      ).show();
      return;
    }

    if (!validatePhoneNumber(telefono)) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.info,
        animType: AnimType.bottomSlide,
        title: 'Alerta',
        desc: 'Por favor introduce un número de teléfono válido.',
        btnOkText: 'Cerrar',
        btnOkOnPress: () {

        },
      ).show();
      return;
    }

    if (!validatePassword(password)) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.info,
        animType: AnimType.bottomSlide,
        title: 'Alerta',
        desc: 'La contraseña debe tener al menos 8 caracteres, una letra mayúscula, un número y un signo especial.',
        btnOkText: 'Cerrar',
        btnOkOnPress: () {

        },
      ).show();
      return;
    }

    if (password != confirmPassword) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.info,
        animType: AnimType.bottomSlide,
        title: 'Alerta',
        desc: 'Las contraseñas no coinciden.',
        btnOkText: 'Cerrar',
        btnOkOnPress: () {

        },
      ).show();
      return;
    }

    final response = await http.post(
      Uri.parse('http://localhost:3000/signup'), // Cambia esto a la URL de tu servidor
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'username': username,
        'nombre': nombre,
        'apellidos': apellidos,
        'telefono': telefono,
        'correo': correo,
        'edad': edad,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      // Registro exitoso
      AwesomeDialog(
        context: context,
        dialogType: DialogType.info,
        animType: AnimType.bottomSlide,
        title: 'Exito!',
        desc: 'Usuario registrado correctamente.',
        btnOkText: 'Cerrar',
        btnOkOnPress: () {
          Navigator.pushNamed(context, '/home');
        },
      ).show();
    } else {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.info,
        animType: AnimType.bottomSlide,
        title: 'Oooooh no!',
        desc: 'Error al registrar el registar el usuario',
        btnOkText: 'Cerrar',
        btnOkOnPress: () {

        },
      ).show();
      _showErrorDialog(context, 'Error al registrar usuario: ${response.body}');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 171, 171, 245),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                const Text(
                  'Registrarse',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentColor,
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(20),
                  width: 300, // Reduce el ancho del contenedor
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          hintText: 'Username',
                          prefixIcon: Icon(Icons.account_circle, color: AppColors.primaryColor),
                          filled: true,
                          fillColor: Colors.white,
                          border: InputBorder.none, // Quita el borde del campo
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _nombreController,
                        decoration: const InputDecoration(
                          hintText: 'Nombre',
                          prefixIcon: Icon(Icons.person, color: AppColors.primaryColor),
                          filled: true,
                          fillColor: Colors.white,
                          border: InputBorder.none,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _apellidosController,
                        decoration: const InputDecoration(
                          hintText: 'Apellidos',
                          prefixIcon: Icon(Icons.person, color: AppColors.primaryColor),
                          filled: true,
                          fillColor: Colors.white,
                          border: InputBorder.none,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _telefonoController,
                        decoration: const InputDecoration(
                          hintText: 'Teléfono',
                          prefixIcon: Icon(Icons.phone, color: AppColors.primaryColor),
                          filled: true,
                          fillColor: Colors.white,
                          border: InputBorder.none,
                        ),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _correoController,
                        decoration: const InputDecoration(
                          hintText: 'Correo',
                          prefixIcon: Icon(Icons.email, color: AppColors.primaryColor),
                          filled: true,
                          fillColor: Colors.white,
                          border: InputBorder.none,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _edadController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          hintText: 'Edad',
                          prefixIcon: Icon(Icons.calendar_today, color: AppColors.primaryColor),
                          filled: true,
                          fillColor: Colors.white,
                          border: InputBorder.none,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: 'Contraseña',
                          prefixIcon: Icon(Icons.lock, color: AppColors.primaryColor),
                          filled: true,
                          fillColor: Colors.white,
                          border: InputBorder.none,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: 'Confirmar Contraseña',
                          prefixIcon: Icon(Icons.lock, color: AppColors.primaryColor),
                          filled: true,
                          fillColor: Colors.white,
                          border: InputBorder.none,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          registerUser(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text('Registrar',
                        style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: const Text('Ya tengo una cuenta'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
