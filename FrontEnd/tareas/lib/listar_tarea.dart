import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';

void main() {
  runApp(ListarTareasApp());
}

class ListarTareasApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Tareas',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ListarTareasScreen(),
    );
  }
}

class ListarTareasScreen extends StatefulWidget {
  @override
  _ListarTareasScreenState createState() => _ListarTareasScreenState();
}

class _ListarTareasScreenState extends State<ListarTareasScreen> {
  List tasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _obtenerTareas();
  }

  Future<void> _obtenerTareas() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/listTasks'));

      if (response.statusCode == 200) {
        setState(() {
          tasks = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showErrorDialog('No se pudieron obtener las tareas.');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Error al conectar con el servidor.');
    }
  }

  void _showErrorDialog(String mensaje) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _updateTask(Map task) async {
  final TextEditingController tituloController =
      TextEditingController(text: task['Titulo']);
  final TextEditingController descripcionController =
      TextEditingController(text: task['Descripcion']);

  showDialog(
    context: context,
    barrierColor: Colors.black54,  // Sombreado sutil en el fondo
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Actualizar Tarea',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Campo para el título de la tarea
              TextField(
                controller: tituloController,
                decoration: InputDecoration(
                  labelText: 'Título',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Campo para la descripción de la tarea
              TextField(
                controller: descripcionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Botones para guardar y cancelar
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();  // Cierra el diálogo
                    },
                    child: Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      final updatedTask = {
                        'id': task['id'],
                        'Titulo': tituloController.text,
                        'Descripcion': descripcionController.text,
                        'FechaLimite': task['FechaLimite'],
                        'Ubicacion': task['Ubicacion'],
                      };

                      try {
                        final response = await http.put(
                          Uri.parse('http://localhost:3000/updateTask/${task['id']}'),
                          headers: {'Content-Type': 'application/json'},
                          body: json.encode(updatedTask),
                        );

                        Navigator.of(context).pop();  // Cierra el diálogo

                        if (response.statusCode == 200) {
                          _showAwesomeDialog('Éxito', 'Tarea actualizada correctamente', DialogType.success);
                          setState(() {
                            _obtenerTareas();  // Actualiza tu lista de tareas
                          });
                        } else {
                          _showAwesomeDialog('Error', 'Error al actualizar la tarea', DialogType.error);
                        }
                      } catch (e) {
                        print('Error: $e');
                        Navigator.of(context).pop();
                        _showAwesomeDialog('Error', 'No se pudo conectar al servidor', DialogType.error);
                      }
                    },
                    child: Text('Guardar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

// Función para mostrar AwesomeDialog
void _showAwesomeDialog(String title, String message, DialogType dialogType) {
  AwesomeDialog(
    context: context,
    dialogType: dialogType,
    animType: AnimType.bottomSlide,
    title: title,
    desc: message,
    btnOkText: 'OK',
    btnOkOnPress: () {
      // Acción al cerrar el mensaje OK
    },
  )..show();
}


  void _moveToTerminadas(Map task) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Mover a Terminadas'),
          content: Text('¿Estás seguro de mover esta tarea a tareas terminadas?'),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {
                try {
                  final response = await http.post(
                    Uri.parse('http://localhost:3000/moveToTerminadas'),
                    headers: {'Content-Type': 'application/json'},
                    body: json.encode(task),
                  );

                  if (response.statusCode == 200) {
                    setState(() {
                      tasks.removeWhere((t) => t['id'] == task['id']);
                    });
                    Navigator.of(context).pop();
                    _showSuccessDialog('Tarea movida a Terminadas');
                  }
                } catch (e) {
                  Navigator.of(context).pop();
                  _showErrorDialog('Error al mover la tarea a Terminadas');
                }
              },
              child: Text('Sí'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(context).pop(),
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Tareas'),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : tasks.isEmpty
              ? Center(child: Text('No hay tareas creadas'))
              : ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];

                    return Card(
                      color: Colors.teal.shade50,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.check_circle, color: Colors.teal),
                        title: Text(task['Titulo']),
                        subtitle: Text(task['Descripcion'] ?? 'Sin descripción'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.orange),
                              onPressed: () => _updateTask(task),
                            ),
                            IconButton(
                              icon: Icon(Icons.check_circle_outline, color: Colors.green),
                              onPressed: () => _moveToTerminadas(task),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
