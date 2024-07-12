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
  String? _nombreError;
  String? _cedulaError;
  String? _telefonoError;
  String? _direccionError;
  String? _emailError;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.cliente?['nombre'] ?? '');
    _cedulaController = TextEditingController(text: widget.cliente?['cedula'] ?? '');
    _telefonoController = TextEditingController(text: widget.cliente?['telefono'] ?? '');
    _direccionController = TextEditingController(text: widget.cliente?['direccion'] ?? '');
    _emailController = TextEditingController(text: widget.cliente?['email'] ?? '');

    if (widget.cliente?['tipodoc'] != null && _tipoDocMap.containsValue(widget.cliente!['tipodoc'])) {
      _selectedTipoDoc = _tipoDocMap.entries.firstWhere((element) => element.value == widget.cliente!['tipodoc']).key;
    }

    _nombreController.addListener(_validateNombre);
    _cedulaController.addListener(_validateCedula);
    _telefonoController.addListener(_validateTelefono);
    _direccionController.addListener(_validateDireccion);
    _emailController.addListener(_validateEmail);
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

  void _validateNombre() {
    final nombre = _nombreController.text.trim();
    if (nombre.isEmpty) {
      setState(() {
        _nombreError = 'El campo "nombre" no puede estar vacío';
      });
    } else if (nombre.length < 6 || nombre.length > 30) {
      setState(() {
        _nombreError = 'El campo "nombre" debe tener entre 6 y 30 caracteres';
      });
    } else if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ ]+$').hasMatch(nombre)) {
      setState(() {
        _nombreError = 'El campo "nombre" debe contener solo letras';
      });
    } else {
      setState(() {
        _nombreError = null;
      });
    }
  }

  void _validateCedula() {
    final cedula = _cedulaController.text.trim();
    if (cedula.isEmpty) {
      setState(() {
        _cedulaError = 'El campo "cédula" no puede estar vacío';
      });
    } else if (cedula.length < 10 || cedula.length > 13) {
      setState(() {
        _cedulaError = 'El campo "cédula" debe tener entre 10 y 13 caracteres';
      });
    } else if (!RegExp(r'^[0-9]+$').hasMatch(cedula)) {
      setState(() {
        _cedulaError = 'El campo "cédula" debe contener solo números';
      });
    } else {
      setState(() {
        _cedulaError = null;
      });
    }
  }

  void _validateTelefono() {
    final telefono = _telefonoController.text.trim();
    if (telefono.isEmpty) {
      setState(() {
        _telefonoError = 'El campo "teléfono" no puede estar vacío';
      });
    } else if (telefono.length < 7 || telefono.length > 10) {
      setState(() {
        _telefonoError = 'El campo "teléfono" debe tener entre 7 y 10 caracteres';
      });
    } else if (!RegExp(r'^[0-9]+$').hasMatch(telefono)) {
      setState(() {
        _telefonoError = 'El campo "teléfono" debe contener solo números';
      });
    } else {
      setState(() {
        _telefonoError = null;
      });
    }
  }

  void _validateDireccion() {
    final direccion = _direccionController.text.trim();
    if (direccion.isEmpty) {
      setState(() {
        _direccionError = 'El campo "dirección" no puede estar vacío';
      });
    } else if (direccion.length > 60) {
      setState(() {
        _direccionError = 'El campo "dirección" debe tener como máximo 60 caracteres';
      });
    } else {
      setState(() {
        _direccionError = null;
      });
    }
  }

  void _validateEmail() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _emailError = 'El campo "email" no puede estar vacío';
      });
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email)) {
      setState(() {
        _emailError = 'El campo "email" debe ser un correo válido';
      });
    } else {
      setState(() {
        _emailError = null;
      });
    }
  }

  Future<void> _guardarCliente() async {
    _validateNombre();
    _validateCedula();
    _validateTelefono();
    _validateDireccion();
    _validateEmail();

    if (_formKey.currentState!.validate() && _nombreError == null && _cedulaError == null && _telefonoError == null && _direccionError == null && _emailError == null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null) {
        return;
      }

      bool success;
      try {
        if (widget.cliente == null) {
          success = await ApiService.guardarCliente(
            token: token,
            nombre: _nombreController.text.trim(),
            cedula: _cedulaController.text.trim(),
            telefono: _telefonoController.text.trim(),
            direccion: _direccionController.text.trim(),
            email: _emailController.text.trim(),
            tipodoc: _tipoDocMap[_selectedTipoDoc]!,
          );
        } else {
          final clienteId = widget.cliente!['_id'].toString();
          if (clienteId.isEmpty) {
            throw Exception('El ID del cliente no puede estar vacío');
          }
          success = await ApiService.modificarCliente(
            token: token,
            id: clienteId,
            nombre: _nombreController.text.trim(),
            cedula: _cedulaController.text.trim(),
            telefono: _telefonoController.text.trim(),
            direccion: _direccionController.text.trim(),
            email: _emailController.text.trim(),
            tipodoc: _tipoDocMap[_selectedTipoDoc]!,
          );
        }

        if (success) {
          final clienteModificado = {
            '_id': widget.cliente?['_id'],
            'nombre': _nombreController.text.trim(),
            'cedula': _cedulaController.text.trim(),
            'telefono': _telefonoController.text.trim(),
            'direccion': _direccionController.text.trim(),
            'email': _emailController.text.trim(),
            'tipodoc': _tipoDocMap[_selectedTipoDoc],
          };

          Navigator.pop(context, clienteModificado);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar el cliente')),
          );
        }
      } catch (e) {
        print('Error al guardar el cliente: $e');
        String errorMessage = '';
        if (e.toString().contains('La cédula ya se encuentra registrada')) {
          errorMessage = 'La cédula ya se encuentra registrada';
        } else if (e.toString().contains('El correo ya se encuentra registrado')) {
          errorMessage = 'El correo ya se encuentra registrado';
        } else {
          errorMessage = 'Error al guardar el cliente';
        }
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
        title: Text(
          widget.cliente != null ? 'Modificar Cliente' : 'Nuevo Cliente',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xff5511b0),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white), // Cambia la flecha a blanco
      ),
      backgroundColor: Color(0xFF0A192F),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.person_outline, size: 100, color: Color(0xffEBDCFA)), // Ícono de cliente
                SizedBox(height: 20),
                _TextFieldCustom(
                  icono: Icons.person_outline,
                  type: TextInputType.text,
                  texto: 'Nombre y Apellido',
                  controller: _nombreController,
                  errorText: _nombreError,
                  maxLength: 30,
                ),
                SizedBox(height: 20),
                _TextFieldCustom(
                  icono: Icons.credit_card,
                  type: TextInputType.number,
                  texto: 'Cédula',
                  controller: _cedulaController,
                  errorText: _cedulaError,
                  maxLength: 13,
                ),
                SizedBox(height: 20),
                _TextFieldCustom(
                  icono: Icons.phone,
                  type: TextInputType.phone,
                  texto: 'Teléfono',
                  controller: _telefonoController,
                  errorText: _telefonoError,
                  maxLength: 10,
                ),
                SizedBox(height: 20),
                _TextFieldCustom(
                  icono: Icons.location_on,
                  type: TextInputType.text,
                  texto: 'Dirección',
                  controller: _direccionController,
                  errorText: _direccionError,
                  maxLength: 60,
                  showCounter: true,
                ),
                SizedBox(height: 20),
                _TextFieldCustom(
                  icono: Icons.email,
                  type: TextInputType.emailAddress,
                  texto: 'Email',
                  controller: _emailController,
                  errorText: _emailError,
                ),
                SizedBox(height: 20), // Añadir espacio antes del dropdown
                DropdownButtonFormField<String>(
                  value: _selectedTipoDoc,
                  hint: Text('Seleccione tipo de identificación', style: TextStyle(color: Colors.grey)),
                  items: _tipoDocList.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: TextStyle(color: Colors.black)),
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
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xffEBDCFA),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xffEBDCFA)),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xffEBDCFA)),
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _guardarCliente,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff5511b0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: Text('Guardar Cliente', style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TextFieldCustom extends StatelessWidget {
  final IconData icono;
  final TextInputType type;
  final String texto;
  final TextEditingController controller;
  final String? errorText;
  final int? maxLength;
  final bool showCounter;

  const _TextFieldCustom({
    Key? key,
    required this.icono,
    required this.type,
    required this.texto,
    required this.controller,
    this.errorText,
    this.maxLength,
    this.showCounter = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Stack(
        children: [
          TextField(
            controller: controller,
            keyboardType: type,
            maxLength: maxLength,
            decoration: InputDecoration(
              hintText: texto,
              filled: true,
              fillColor: Color(0xffEBDCFA),
              prefixIcon: Icon(icono, color: Colors.grey),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xffEBDCFA)),
                borderRadius: BorderRadius.circular(50),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xffEBDCFA)),
                borderRadius: BorderRadius.circular(50),
              ),
              errorText: errorText,
              counterText: '',
            ),
            onChanged: (value) {
              if (maxLength != null && value.length > maxLength!) {
                controller.text = value.substring(0, maxLength!);
                controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: maxLength!),
                );
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Se permite hasta $maxLength caracteres en el campo $texto'),
                ));
              }
            },
          ),
          if (showCounter)
            Positioned(
              right: 16,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  '${controller.text.length}/${maxLength ?? ''}',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
