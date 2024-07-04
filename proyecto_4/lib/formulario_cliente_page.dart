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
        return;
      }

      bool success;
      try {
        if (widget.cliente == null) {
          success = await ApiService.guardarCliente(
            token: token,
            nombre: _nombreController.text,
            cedula: _cedulaController.text,
            telefono: _telefonoController.text,
            direccion: _direccionController.text,
            email: _emailController.text,
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
            nombre: _nombreController.text,
            cedula: _cedulaController.text,
            telefono: _telefonoController.text,
            direccion: _direccionController.text,
            email: _emailController.text,
            tipodoc: _tipoDocMap[_selectedTipoDoc]!,
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
        backgroundColor: Color(0xff5511b0),
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
                _TextFieldCustom(
                  icono: Icons.person_outline,
                  type: TextInputType.text,
                  texto: 'Nombre',
                  controller: _nombreController,
                ),
                _TextFieldCustom(
                  icono: Icons.credit_card,
                  type: TextInputType.number,
                  texto: 'Cédula',
                  controller: _cedulaController,
                ),
                _TextFieldCustom(
                  icono: Icons.phone,
                  type: TextInputType.phone,
                  texto: 'Teléfono',
                  controller: _telefonoController,
                ),
                _TextFieldCustom(
                  icono: Icons.location_on,
                  type: TextInputType.text,
                  texto: 'Dirección',
                  controller: _direccionController,
                ),
                _TextFieldCustom(
                  icono: Icons.email,
                  type: TextInputType.emailAddress,
                  texto: 'Email',
                  controller: _emailController,
                ),
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

  const _TextFieldCustom({
    Key? key,
    required this.icono,
    required this.type,
    required this.texto,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller,
        keyboardType: type,
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
        ),
      ),
    );
  }
}