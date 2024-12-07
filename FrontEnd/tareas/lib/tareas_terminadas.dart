import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TareasTerminadas extends StatefulWidget {
  @override
  _TareasTerminadasState createState() => _TareasTerminadasState();
}

class _TareasTerminadasState extends State<TareasTerminadas> {
  List<Map<String, dynamic>> terminadas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTerminadas();
  }

  void fetchTerminadas() async {
  try {
    final response = await http.get(Uri.parse('http://localhost:3000/terminadas'));

    if (response.statusCode == 200) {
      List tasks = jsonDecode(response.body);

      setState(() {
        terminadas = tasks.map((task) {
          return {
            'Titulo': task['titulo'] ?? 'Título no disponible',
            'Descripcion': task['descripcion'] ?? 'Sin descripción'
          };
        }).toList();

        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print('Error al obtener tareas terminadas');
    }
  } catch (e) {
    print('Error al cargar tareas: $e');
    setState(() {
      isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tareas Terminadas'),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : terminadas.isEmpty
              ? Center(child: Text('No hay tareas terminadas'))
              : ListView.builder(
                  itemCount: terminadas.length,
                  itemBuilder: (context, index) {
                    final task = terminadas[index];

                    // Verificar si las claves existen y no son nulas
                    final titulo = task['Titulo'] ?? 'Título no disponible';
                    final descripcion = task['Descripcion'] ?? 'Sin descripción';

                    return Card(
                      color: Colors.amber.shade50,  // Color amarillo elegante
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.check_circle, color: Colors.green),
                        title: Text(titulo),
                        subtitle: Text(descripcion),
                      ),
                    );
                  },
                ),
    );
  }
}
