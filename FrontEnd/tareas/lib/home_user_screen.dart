import 'package:flutter/material.dart';
import 'package:tareas/crear_tarea.dart';
import 'colors.dart'; // Asegúrate de que este archivo exista y contenga tus colores

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tasky',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeUserScreen(),
      routes: {
        '/crear_tarea': (context) => CrearTareas(),
        '/ver_tareas': (context) => VerTareasScreen(),
        '/ver_tareas_terminadas': (context) => VerTareasTerminadasScreen(),
        '/mostrar_estadisticas': (context) => MostrarEstadisticasScreen(),
      },
    );
  }
}

class HomeUserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tasky',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(
              Icons.person,
              color: Colors.white,
            ),
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'profile',
                  child: Text('Perfil'),
                ),
                PopupMenuItem<String>(
                  value: 'settings',
                  child: Text('Configuraciones'),
                ),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Text('Cerrar sesión'),
                ),
              ];
            },
            onSelected: (String value) {
              // Acciones según la opción seleccionada
              switch (value) {
                case 'profile':
                  // Navegar a la pantalla de perfil
                  break;
                case 'settings':
                  // Navegar a la pantalla de configuraciones
                  break;
                case 'logout':
                  // Realizar la acción de cerrar sesión
                  break;
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/crear_tarea'); // Navegar a crear tareas
                    },
                    child: Container(
                      margin: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Center(
                        child: Text(
                          'Crear Tarea',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/ver_tareas'); // Navegar a ver tareas
                    },
                    child: Container(
                      margin: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryColor.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Center(
                        child: Text(
                          'Ver Tareas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/ver_tareas_terminadas'); // Navegar a ver tareas terminadas
                    },
                    child: Container(
                      margin: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: AppColors.tertiaryColor.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Center(
                        child: Text(
                          'Ver Tareas Terminadas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/mostrar_estadisticas'); // Navegar a mostrar estadísticas
                    },
                    child: Container(
                      margin: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: AppColors.quaternaryColor.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Center(
                        child: Text(
                          'Mostrar Estadísticas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CrearTareasScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Tareas'),
      ),
      body: Center(
        child: Text('Aquí puedes crear tareas.'),
      ),
    );
  }
}

class VerTareasScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ver Tareas'),
      ),
      body: Center(
        child: Text('Aquí puedes ver las tareas.'),
      ),
    );
  }
}

class VerTareasTerminadasScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ver Tareas Terminadas'),
      ),
      body: Center(
        child: Text('Aquí puedes ver las tareas terminadas.'),
      ),
    );
  }
}

class MostrarEstadisticasScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mostrar Estadísticas'),
      ),
      body: Center(
        child: Text('Aquí puedes ver las estadísticas.'),
      ),
    );
  }
}
