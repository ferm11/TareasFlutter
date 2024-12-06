import 'package:http/http.dart' as http;
import 'dart:convert';

class TaskService {
  static const String baseUrl = 'http://localhost:3000/tasks';

  // Obtener todas las tareas
  static Future<List> fetchTasks() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al cargar las tareas');
    }
  }

  // Crear una nueva tarea
  static Future<void> createTask(Map<String, dynamic> taskData) async {
    final response = await http.post(Uri.parse(baseUrl), body: taskData);
    if (response.statusCode != 201) {
      throw Exception('Error al crear la tarea');
    }
  }

  // Actualizar una tarea existente
  static Future<void> updateTask(int id, Map<String, dynamic> taskData) async {
    final response = await http.put(Uri.parse('$baseUrl/$id'), body: taskData);
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar la tarea');
    }
  }

  // Eliminar una tarea
  static Future<void> deleteTask(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar la tarea');
    }
  }
}
