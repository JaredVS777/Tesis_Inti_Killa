import 'package:flutter/material.dart';
import 'package:proyecto/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormularioClientePage extends StatefulWidget {
  final Map<String, dynamic>? cliente;

  FormularioClientePage({this.cliente});

  @override
  _FormularioClientePageState createState() => _FormularioClientePageState();
}

class _FormularioClientePageState extends State<FormularioClientePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _cedulaController;
  late TextEditingController _telefonoController;
  late TextEditingController _direccionController;
  late TextEditingController _emailController;

  final List<String> _tipoDocList = [
    'RUC',
    'CÉDULA',
    'PASAPORTE',
    'VENTA A CONSUMIDOR FINAL',
    'IDENTIFICACION DEL EXTERIOR'
  ];

  final Map<String, String> _tipoDocMap = {
    'RUC': '04',
    'CÉDULA': '05',
    'PASAPORTE': '06',
    'VENTA A CONSUMIDOR FINAL': '07',
    'IDENTIFICACION DEL EXTERIOR': '08'
  };

  String? _selectedTipoDoc;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.cliente?['nombre'] ?? '');
    _cedulaController = TextEditingController(text: widget.cliente?['cedula'] ?? '');
    _telefonoController = TextEditingController(text: widget.cliente?['telefono'] ?? '');
    _direccionController = TextEditingController(text: widget.cliente?['direccion'] ?? '');
    _emailController = TextEditingController(text: widget.cliente?['email'] ?? '');

    // Verificar que el valor inicial de _selectedTipoDoc sea válido
    if (widget.cliente?['tipodoc'] != null && _tipoDocMap.containsValue(widget.cliente!['tipodoc'])) {
      _selectedTipoDoc = _tipoDocMap.entries.firstWhere((element) => element.value == widget.cliente!['tipodoc']).key;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _cedulaController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _guardarCliente() async {
    if (_formKey.currentState!.validate()) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null) {
        // Handle authentication error
        return;
      }

      bool success;
      try {
        if (widget.cliente == null) {
          print('Intentando guardar un nuevo cliente');
          print('Datos del cliente: ${_nombreController.text}, ${_cedulaController.text}, ${_telefonoController.text}, ${_direccionController.text}, ${_emailController.text}, $_selectedTipoDoc');
          success = await ApiService.guardarCliente(
            token: token,
            nombre: _nombreController.text,
            cedula: _cedulaController.text,
            telefono: _telefonoController.text,
            direccion: _direccionController.text,
            email: _emailController.text,
            tipodoc: _tipoDocMap[_selectedTipoDoc]!, // Asegúrate de enviar el tipodoc seleccionado
          );
        } else {
          final clienteId = widget.cliente!['_id'].toString();
          if (clienteId.isEmpty) {
            throw Exception('El ID del cliente no puede estar vacío');
          }
          print('Intentando modificar el cliente con ID: $clienteId');
          print('Datos del cliente: ${_nombreController.text}, ${_cedulaController.text}, ${_telefonoController.text}, ${_direccionController.text}, ${_emailController.text}, $_selectedTipoDoc');
          success = await ApiService.modificarCliente(
            token: token,
            id: clienteId,
            nombre: _nombreController.text,
            cedula: _cedulaController.text,
            telefono: _telefonoController.text,
            direccion: _direccionController.text,
            email: _emailController.text,
            tipodoc: _tipoDocMap[_selectedTipoDoc]!, // Asegúrate de enviar el tipodoc seleccionado
          );
        }

        if (success) {
          final clienteModificado = {
            '_id': widget.cliente?['_id'],
            'nombre': _nombreController.text,
            'cedula': _cedulaController.text,
            'telefono': _telefonoController.text,
            'direccion': _direccionController.text,
            'email': _emailController.text,
            'tipodoc': _tipoDocMap[_selectedTipoDoc], // Asegúrate de incluir el tipodoc
          };

          Navigator.pop(context, clienteModificado);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar el cliente')),
          );
        }
      } catch (e) {
        print('Error al guardar el cliente: $e');
        String errorMessage = e.toString().contains('La cédula ya se encuentra registrada')
            ? 'La cédula ya se encuentra registrada'
            : 'Error al guardar el cliente';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cliente != null ? 'Modificar Cliente' : 'Nuevo Cliente'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SizedBox(
            width: 300,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.person,
                    size: 120,
                    color: Theme.of(context).primaryColor,
                  ),
                  TextFormField(
                    controller: _nombreController,
                    decoration: InputDecoration(labelText: 'Nombre'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese un nombre';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _cedulaController,
                    decoration: InputDecoration(labelText: 'Cédula'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese una cédula';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _telefonoController,
                    decoration: InputDecoration(labelText: 'Teléfono'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese un teléfono';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _direccionController,
                    decoration: InputDecoration(labelText: 'Dirección'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese una dirección';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese un email';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedTipoDoc,
                    hint: Text('Seleccione Tipo de Identificación'),
                    items: _tipoDocList.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedTipoDoc = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Por favor seleccione un tipo de identificación';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _guardarCliente,
                    child: Text('Guardar Cliente'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
