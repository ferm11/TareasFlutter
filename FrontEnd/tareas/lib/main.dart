import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:url_launcher/url_launcher.dart';

// Pantallas existentes
import 'login_screen.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import 'home_user_screen.dart';
import 'crear_tarea.dart';

// Pantallas nuevas
import 'task_list_screen.dart';
import 'task_form_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      home: HomeScreen(), // Cambia la pantalla inicial si es necesario
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/home_user_screen': (context) => HomeUserScreen(),
        '/crear_tarea': (context) => CrearTareas(),
        '/task_list': (context) => TaskListScreen(), // Nueva ruta para la lista de tareas
        '/task_form': (context) => TaskFormScreen(onSave: () {}), // Nueva ruta para el formulario de tareas
      },
    );
  }
}

// Función para abrir una URL
Future<void> launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'No se pudo abrir $url';
  }
}
