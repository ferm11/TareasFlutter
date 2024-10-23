import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tareas/crear_tarea.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import 'home_user_screen.dart';
import 'package:firebase_core/firebase_core.dart'; // Importa Firebase
import 'firebase_options.dart'; // Importa el archivo de configuración generado por FlutterFire
import 'package:url_launcher/url_launcher.dart'; // Importa url_launcher
import 'package:tareas/crear_tarea.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa Firebase con las opciones
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
        '/crear_tarea': (context) => CrearTareas(),
      },
    );
  }
}

// Ejemplo de función para abrir una URL
Future<void> launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'No se pudo abrir $url';
  }
}
