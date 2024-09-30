import 'package:flutter/material.dart';
import 'colors.dart';  // Asegúrate de definir tus colores en colors.dart

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,  // Color de fondo elegante
      body: SafeArea(
        child: Center(  // Centrar el contenido en la pantalla
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,  // Centrar verticalmente
              crossAxisAlignment: CrossAxisAlignment.center,  // Centrar horizontalmente
              children: [
                // Icono o ilustración central alusiva a tareas
                Icon(
                  Icons.check_circle_outline,
                  size: 120,
                  color: AppColors.accentColor,  // Color llamativo del ícono
                ),
                SizedBox(height: 30),
                // Título principal
                Text(
                  '¡Bienvenido a Mis Recordatorios!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                // Subtítulo motivacional
                Text(
                  'Organiza tus tareas de forma fácil y rápida. Mantén todo bajo control.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                SizedBox(height: 50),  // Espaciado mayor antes del botón
                // Botón de acción (ir a login o tareas)
                ElevatedButton(
                  onPressed: () {
                    // Navegar a la pantalla de inicio de sesión
                    Navigator.pushNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentColor,  // Color llamativo
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Comenzar',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
