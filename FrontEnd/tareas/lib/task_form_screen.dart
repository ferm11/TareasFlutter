import 'package:flutter/material.dart';
import 'task_service.dart';

class TaskFormScreen extends StatefulWidget {
  final Map? task;
  final Function onSave;

  TaskFormScreen({this.task, required this.onSave});

  @override
  _TaskFormScreenState createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String titulo = '';
  String descripcion = '';
  String fechaLimite = '';
  String ubicacion = '';

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      titulo = widget.task!['Titulo'];
      descripcion = widget.task!['Descripcion'];
      fechaLimite = widget.task!['FechaLimite'];
      ubicacion = widget.task!['Ubicacion'];
    }
  }

  Future<void> saveTask() async {
    try {
      if (widget.task == null) {
        await TaskService.createTask({
          'Titulo': titulo,
          'Descripcion': descripcion,
          'FechaLimite': fechaLimite,
          'Ubicacion': ubicacion,
        });
      } else {
        await TaskService.updateTask(widget.task!['id'], {
          'Titulo': titulo,
          'Descripcion': descripcion,
          'FechaLimite': fechaLimite,
          'Ubicacion': ubicacion,
        });
      }
      widget.onSave();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la tarea')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Nueva Tarea' : 'Editar Tarea'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: titulo,
                decoration: InputDecoration(labelText: 'Título'),
                onChanged: (value) => titulo = value,
              ),
              TextFormField(
                initialValue: descripcion,
                decoration: InputDecoration(labelText: 'Descripción'),
                onChanged: (value) => descripcion = value,
              ),
              TextFormField(
                initialValue: fechaLimite,
                decoration: InputDecoration(labelText: 'Fecha Límite (YYYY-MM-DD)'),
                onChanged: (value) => fechaLimite = value,
              ),
              TextFormField(
                initialValue: ubicacion,
                decoration: InputDecoration(labelText: 'Ubicación'),
                onChanged: (value) => ubicacion = value,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Guardar'),
                onPressed: saveTask,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
