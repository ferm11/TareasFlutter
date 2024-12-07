import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CrearTareas extends StatefulWidget {
  const CrearTareas({super.key});

  @override
  _CrearTareasState createState() => _CrearTareasState();
}

class _CrearTareasState extends State<CrearTareas> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _ubicacionController = TextEditingController();
  DateTime _fechaFin = DateTime.now();

  void _saveTask() async {
    final String titulo = _tituloController.text;
    final String descripcion = _descripcionController.text;
    final String ubicacion = _ubicacionController.text;
    final String fechaLimite = DateFormat('yyyy-MM-dd').format(_fechaFin);

    if (titulo.isEmpty || descripcion.isEmpty || fechaLimite.isEmpty || ubicacion.isEmpty) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.info,
        animType: AnimType.bottomSlide,
        title: 'Alerta',
        desc: 'Por favor, llena todos los campos.',
        btnOkText: 'Cerrar',
        btnOkOnPress: () {},
      ).show();
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/tasks'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'Titulo': titulo,
          'Descripcion': descripcion,
          'FechaLimite': fechaLimite,
          'Ubicacion': ubicacion,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.bottomSlide,
          title: 'Éxito!',
          desc: 'Tarea creada exitosamente.',
          btnOkText: 'Cerrar',
          btnOkOnPress: () {
            Navigator.pop(context);
          },
        ).show();
        _tituloController.clear();
        _descripcionController.clear();
        _ubicacionController.clear();
      } else {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.bottomSlide,
          title: 'Error',
          desc: 'No se pudo crear la tarea.',
          btnOkText: 'Cerrar',
          btnOkOnPress: () {},
        ).show();
      }
    } catch (e) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.bottomSlide,
        title: 'Error de conexión',
        desc: 'No se pudo conectar al servidor.',
        btnOkText: 'Cerrar',
        btnOkOnPress: () {},
      ).show();
    }
  }

  Future<void> _seleccionarFechaFin(BuildContext context) async {
    final DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: _fechaFin,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (fechaSeleccionada != null) {
      setState(() {
        _fechaFin = fechaSeleccionada;
      });
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _ubicacionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Crear Tarea'),
        backgroundColor: Colors.indigoAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildInputField(_tituloController, 'Título', Icons.title),
              _buildInputField(_descripcionController, 'Descripción', Icons.description, maxLines: 3),
              _buildInputField(_ubicacionController, 'Ubicación', Icons.location_on),
              const SizedBox(height: 16),

              _buildFechaCard(),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigoAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Crear Tarea'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildFechaCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.calendar_today, color: Colors.indigoAccent),
        title: Text('Fecha de Finalización: ${DateFormat('yyyy-MM-dd').format(_fechaFin)}'),
        trailing: IconButton(
          icon: Icon(Icons.edit_calendar, color: Colors.grey),
          onPressed: () => _seleccionarFechaFin(context),
        ),
      ),
    );
  }
}
