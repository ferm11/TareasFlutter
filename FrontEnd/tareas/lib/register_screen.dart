import 'package:flutter/material.dart';
import 'colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart'; // Para FilteringTextInputFormatter

class RegisterScreen extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

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
      _showErrorDialog(context, 'Por favor completa todos los campos.');
      return;
    }

    if (!validateEmail(correo)) {
      _showErrorDialog(context, 'Por favor introduce un correo electrónico válido.');
      return;
    }

    if (!validatePhoneNumber(telefono)) {
      _showErrorDialog(context, 'Por favor introduce un número de teléfono válido.');
      return;
    }

    if (!validatePassword(password)) {
      _showErrorDialog(context, 'La contraseña debe tener al menos 8 caracteres, una letra mayúscula, un número y un signo especial.');
      return;
    }

    if (password != confirmPassword) {
      _showErrorDialog(context, 'Las contraseñas no coinciden.');
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuario registrado correctamente')),
      );
      Navigator.pushNamed(context, '/login');
    } else {
      _showErrorDialog(context, 'Error al registrar usuario: ${response.body}');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Aceptar'),
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
                SizedBox(height: 40),
                Text(
                  'Registrarse',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentColor,
                  ),
                ),
                SizedBox(height: 40),
                Container(
                  padding: EdgeInsets.all(20),
                  width: 300, // Reduce el ancho del contenedor
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
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
                        decoration: InputDecoration(
                          hintText: 'Username',
                          prefixIcon: Icon(Icons.account_circle, color: AppColors.primaryColor),
                          filled: true,
                          fillColor: Colors.white,
                          border: InputBorder.none, // Quita el borde del campo
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _nombreController,
                        decoration: InputDecoration(
                          hintText: 'Nombre',
                          prefixIcon: Icon(Icons.person, color: AppColors.primaryColor),
                          filled: true,
                          fillColor: Colors.white,
                          border: InputBorder.none,
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _apellidosController,
                        decoration: InputDecoration(
                          hintText: 'Apellidos',
                          prefixIcon: Icon(Icons.person, color: AppColors.primaryColor),
                          filled: true,
                          fillColor: Colors.white,
                          border: InputBorder.none,
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _telefonoController,
                        decoration: InputDecoration(
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
                      SizedBox(height: 20),
                      TextField(
                        controller: _correoController,
                        decoration: InputDecoration(
                          hintText: 'Correo',
                          prefixIcon: Icon(Icons.email, color: AppColors.primaryColor),
                          filled: true,
                          fillColor: Colors.white,
                          border: InputBorder.none,
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _edadController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          hintText: 'Edad',
                          prefixIcon: Icon(Icons.calendar_today, color: AppColors.primaryColor),
                          filled: true,
                          fillColor: Colors.white,
                          border: InputBorder.none,
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
                          border: InputBorder.none,
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Confirmar Contraseña',
                          prefixIcon: Icon(Icons.lock, color: AppColors.primaryColor),
                          filled: true,
                          fillColor: Colors.white,
                          border: InputBorder.none,
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          registerUser(context);
                        },
                        child: Text('Registrar',
                        style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: EdgeInsets.symmetric(horizontal: 100, vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Text('Ya tengo una cuenta'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
