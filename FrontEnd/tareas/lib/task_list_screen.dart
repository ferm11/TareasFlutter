import 'package:flutter/material.dart';
import 'task_service.dart';
import 'task_form_screen.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List tasks = [];
  String filter = 'Todos';

  // Cargar las tareas al iniciar
  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  // Función para cargar las tareas desde el servicio
  Future<void> loadTasks() async {
    try {
      final fetchedTasks = await TaskService.fetchTasks();
      setState(() {
        tasks = fetchedTasks;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar las tareas')),
      );
    }
  }

  // Función para eliminar una tarea
  Future<void> deleteTask(int id) async {
    try {
      await TaskService.deleteTask(id);
      loadTasks();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tarea eliminada')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar la tarea')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Tareas'),
        actions: [
          DropdownButton<String>(
            value: filter,
            items: ['Todos', 'Fecha más cercana', 'Ubicación']
                .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                .toList(),
            onChanged: (value) {
              setState(() {
                filter = value!;
                // Aquí podrías implementar lógica de filtrado.
              });
            },
          ),
        ],
      ),
      body: tasks.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return ListTile(
                  title: Text(task['Titulo']),
                  subtitle: Text(task['Descripcion']),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteTask(task['id']),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskFormScreen(
                          task: task,
                          onSave: loadTasks,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskFormScreen(onSave: loadTasks),
            ),
          );
        },
      ),
    );
  }
}
