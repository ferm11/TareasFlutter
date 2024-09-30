import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import 'home_user_screen.dart'; 

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recordatorios de Tareas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.robotoTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: HomeScreen(), // Esta es la pantalla que se muestra al inicio
      routes: {
        '/login': (context) => LoginScreen(), // Ruta para la pantalla de login
        '/register': (context) => RegisterScreen(), // Ruta para la pantalla de registro
        '/home': (context) => HomeScreen(), // Ruta para la pantalla principal
        '/home_user_screen': (context) => HomeUserScreen(), // Ruta para la pantalla de bienvenida
      },
    );
  }
}
