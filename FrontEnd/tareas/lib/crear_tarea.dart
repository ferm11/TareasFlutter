import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatear fechas

class CrearTareas extends StatefulWidget {
  @override
  _CrearTareasState createState() => _CrearTareasState();
}

class _CrearTareasState extends State<CrearTareas> {
  final _formKey = GlobalKey<FormState>();
  String? _nombre;
  String? _descripcion;
  DateTime _fechaFin = DateTime.now(); // Fecha de finalización por defecto
  DateTime _fechaCreacion = DateTime.now(); // Fecha de creación por defecto

  void _crearTarea() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Aquí puedes enviar la tarea a tu backend o guardarla en tu base de datos
      print('Nombre: $_nombre');
      print('Descripción: $_descripcion');
      print('Fecha de creación: ${DateFormat('yyyy-MM-dd').format(_fechaCreacion)}');
      print('Fecha de finalización: ${DateFormat('yyyy-MM-dd').format(_fechaFin)}');

      // Puedes mostrar un mensaje de éxito o hacer una navegación hacia otra pantalla
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tarea creada exitosamente')),
      );

      // Limpiar los campos después de la creación
      _formKey.currentState!.reset();
    }
  }

  Future<void> _seleccionarFechaFin(BuildContext context) async {
    final DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: _fechaFin,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (fechaSeleccionada != null && fechaSeleccionada != _fechaFin) {
      setState(() {
        _fechaFin = fechaSeleccionada;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Tarea'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Crear Nueva Tarea',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nombre de la tarea',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa un nombre';
                  }
                  return null;
                },
                onSaved: (value) => _nombre = value,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa una descripción';
                  }
                  return null;
                },
                onSaved: (value) => _descripcion = value,
              ),
              SizedBox(height: 16),
              // Mostrar la fecha de creación
              Text('Fecha de creación: ${DateFormat('yyyy-MM-dd').format(_fechaCreacion)}', style: TextStyle(fontSize: 16)),
              SizedBox(height: 16),
              // Campo para seleccionar la fecha de finalización
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Fecha de finalización: ${DateFormat('yyyy-MM-dd').format(_fechaFin)}'),
                  TextButton(
                    onPressed: () => _seleccionarFechaFin(context),
                    child: Text('Seleccionar fecha'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _crearTarea,
                child: Text('Crear Tarea'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
