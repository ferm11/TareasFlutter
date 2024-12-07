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

  // Obtener las tareas terminadas desde el servidor
  void fetchTerminadas() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/terminadas'));

      if (response.statusCode == 200) {
        setState(() {
          terminadas = List<Map<String, dynamic>>.from(json.decode(response.body));
          isLoading = false;
        });
      } else {
        print('Error al obtener tareas terminadas');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error al cargar tareas terminadas: $e');
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
          ? Center(child: CircularProgressIndicator())  // Indicador de carga
          : terminadas.isEmpty
              ? Center(child: Text('No hay tareas terminadas'))
              : ListView.builder(
                  itemCount: terminadas.length,
                  itemBuilder: (context, index) {
                    final task = terminadas[index];

                    return Card(
                      color: Colors.teal.shade50,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.check_circle, color: Colors.green),
                        title: Text(task['Titulo']),
                        subtitle: Text(task['Descripcion'] ?? 'Sin descripción'),
                      ),
                    );
                  },
                ),
    );
  }
}
