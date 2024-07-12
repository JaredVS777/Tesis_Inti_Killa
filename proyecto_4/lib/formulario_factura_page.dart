import 'package:flutter/material.dart';
import 'api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter/services.dart';

class FormularioFacturaPage extends StatefulWidget {
  @override
  _FormularioFacturaPageState createState() => _FormularioFacturaPageState();
}

class _FormularioFacturaPageState extends State<FormularioFacturaPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _precioUnitarioController = TextEditingController();
  final TextEditingController _totalDescuentoController = TextEditingController();
  final TextEditingController _metodoPagoController = TextEditingController();
  final TextEditingController _clienteController = TextEditingController();

  String _idCliente = '';
  String _idEmpleado = '';
  String _nombreCompletoEmpleado = '';
  List<Map<String, dynamic>> _productos = [];
  double _totalSinImpuestos = 0.0;
  double _totalDescuento = 0.0;
  double _totalImpuestoValor = 0.0;
  double _importeTotal = 0.0;
  List<Map<String, dynamic>> _clientes = [];

  final Map<String, Map<String, dynamic>> _productosEstablecidos = {
    '10': {'nombre': 'Extintor 10lb', 'precio': 30.68},
    '5': {'nombre': 'Extintor 5lb', 'precio': 25.23},
    '20': {'nombre': 'Extintor 20lb', 'precio': 35.46},
    '30': {'nombre': 'Extintor 30lb', 'precio': 40.12},
    '60': {'nombre': 'Extintor CO2 10lb', 'precio': 55.75},
    '90': {'nombre': 'Alarma contra incendios', 'precio': 150},
    '100': {'nombre': 'Gabinete para extintor', 'precio': 35},
    '110': {'nombre': 'Señal salida emergencia', 'precio': 15},
    '70': {'nombre': 'Manguera contra incendios 30m', 'precio': 70.5},
    '130': {'nombre': 'Luces de emergencia', 'precio': 45},
    '120': {'nombre': 'Botiquin primeros auxilios', 'precio': 25},
    '140': {'nombre': 'Cámara de seguridad', 'precio': 120},
  };

  final Map<String, String> _metodoPagoMap = {
    '01': 'SIN SISTEMA FINANCIERO',
    '15': 'COMPENSACION DE DEUDAS',
    '16': 'TARJETA DE DEBITO',
    '17': 'DINERO ELECTRONICO',
    '18': 'TARJETA PREPAGO',
    '19': 'TARJETA DE CREDITO',
    '20': 'OTRO SISTEMA FINANCIERO',
    '21': 'ENDOSO DE TÍTULOS',
  };

  @override
  void initState() {
    super.initState();
    _fetchClientes();
    _setEmpleadoInfo();
    _totalDescuentoController.addListener(_actualizarTotales);
    _codigoController.addListener(_actualizarProductoDesdeCodigo);
  }

  @override
  void dispose() {
    _totalDescuentoController.removeListener(_actualizarTotales);
    _codigoController.removeListener(_actualizarProductoDesdeCodigo);
    _totalDescuentoController.dispose();
    _codigoController.dispose();
    _clienteController.dispose();
    super.dispose();
  }

  void _actualizarProductoDesdeCodigo() {
    final codigo = _codigoController.text;
    if (_productosEstablecidos.containsKey(codigo)) {
      setState(() {
        _nombreProductoSeleccionado = _productosEstablecidos[codigo]!['nombre'];
        _precioUnitarioController.text = _productosEstablecidos[codigo]!['precio'].toString();
      });
    }
  }

  Future<void> _fetchClientes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      List<dynamic> clientes = await ApiService.fetchClientes(token);
      setState(() {
        _clientes = clientes.map((cliente) {
          return {
            'id': cliente['_id'],
            'nombre': cliente['nombre'],
            'cedula': cliente['cedula'],
          };
        }).toList();
      });
    }
  }

  Future<void> _setEmpleadoInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? idEmpleado = prefs.getString('_id');
    String? nombreEmpleado = prefs.getString('nombre');
    String? apellidoEmpleado = prefs.getString('apellido');

    if (idEmpleado != null && nombreEmpleado != null && apellidoEmpleado != null) {
      setState(() {
        _idEmpleado = idEmpleado;
        _nombreCompletoEmpleado = '$nombreEmpleado $apellidoEmpleado';
      });
    }
  }

  void _calcularTotalSinImpuestos() {
    double total = 0.0;
    for (var producto in _productos) {
      total += producto['cantidad'] * producto['precioUnitario'];
    }
    setState(() {
      _totalSinImpuestos = total;
      _actualizarTotales();
    });
  }

  void _actualizarTotales() {
    setState(() {
      _totalDescuento = double.tryParse(_totalDescuentoController.text) ?? 0.0;
      _totalImpuestoValor = _totalSinImpuestos * 0.15;
      _importeTotal = _totalSinImpuestos + _totalImpuestoValor - _totalDescuento;
    });
  }

  void _agregarProducto() {
    if (_codigoController.text.isNotEmpty &&
        _nombreProductoSeleccionado.isNotEmpty &&
        _cantidadController.text.isNotEmpty &&
        _precioUnitarioController.text.isNotEmpty) {
      setState(() {
        _productos.add({
          'codigo': _codigoController.text,
          'nombre': _nombreProductoSeleccionado,
          'cantidad': int.parse(_cantidadController.text),
          'precioUnitario': double.parse(_precioUnitarioController.text),
        });

        _codigoController.clear();
        _cantidadController.clear();
        _precioUnitarioController.clear();

        _calcularTotalSinImpuestos();
      });

      _mostrarBottomSheet();
    }
  }

  void _mostrarBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text('Código')),
                      DataColumn(label: Text('Nombre')),
                      DataColumn(label: Text('Cantidad')),
                      DataColumn(label: Text('Precio Unitario')),
                      DataColumn(label: Text('Acciones')),
                    ],
                    rows: _productos.map((producto) {
                      return DataRow(cells: [
                        DataCell(Text(producto['codigo'])),
                        DataCell(Text(producto['nombre'])),
                        DataCell(Text(producto['cantidad'].toString())),
                        DataCell(Text(producto['precioUnitario'].toString())),
                        DataCell(
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _productos.remove(producto);
                                _calcularTotalSinImpuestos();
                                Navigator.pop(context);
                                _mostrarBottomSheet();
                              });
                            },
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
                _TextFieldCustom(
                  icono: Icons.money,
                  type: TextInputType.number,
                  texto: 'Total sin Impuestos',
                  controller: TextEditingController(
                    text: _totalSinImpuestos.toStringAsFixed(2),
                  ),
                  readOnly: true,
                ),
                _TextFieldCustom(
                  icono: Icons.money_off,
                  type: TextInputType.number,
                  texto: 'Total Descuento',
                  controller: _totalDescuentoController,
                ),
                _TextFieldCustom(
                  icono: Icons.attach_money,
                  type: TextInputType.number,
                  texto: 'Total Impuesto Valor',
                  controller: TextEditingController(
                    text: _totalImpuestoValor.toStringAsFixed(2),
                  ),
                  readOnly: true,
                ),
                _TextFieldCustom(
                  icono: Icons.money,
                  type: TextInputType.number,
                  texto: 'Importe Total',
                  controller: TextEditingController(
                    text: _importeTotal.toStringAsFixed(2),
                  ),
                  readOnly: true,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: Text('Regresar', style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _guardarFactura() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      if (_productos.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Debe agregar al menos un producto')),
        );
        return;
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token != null) {
        try {
          Map<String, dynamic> response = await ApiService.agregarFactura(
            token: token,
            idCliente: _idCliente,
            idEmpleado: _idEmpleado,
            productos: _productos,
            totalSinImpuestos: _totalSinImpuestos,
            totalDescuento: _totalDescuento,
            totalImpuestoValor: _totalImpuestoValor,
            importeTotal: _importeTotal,
            metodoPago: _metodoPagoController.text,
            pagoTotal: _importeTotal,
          );

          if (response.containsKey('mensaje')) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response['mensaje'])),
            );
            Navigator.pop(context, true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Factura guardada con éxito')),
            );
            Navigator.pop(context, true);
          }
        } catch (e) {
          print('Error al agregar la factura: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar la factura')),
          );
        }
      }
    }
  }

  String _nombreProductoSeleccionado = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Formulario de Facturas',
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Color(0xff5511b0),
        iconTheme: IconThemeData(color: Colors.white),
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
                TypeAheadFormField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: _clienteController,
                    decoration: InputDecoration(
                      labelText: 'Nombre del Cliente',
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
                  suggestionsCallback: (pattern) {
                    return _clientes.where((cliente) =>
                        cliente['nombre'].toLowerCase().contains(pattern.toLowerCase()));
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion['nombre']),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    setState(() {
                      _clienteController.text = suggestion['nombre'];
                      _idCliente = suggestion['id'];
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, seleccione un cliente';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    final cliente = _clientes.firstWhere((cliente) => cliente['nombre'] == value, orElse: () => {'id': ''});
                    _idCliente = cliente['id'];
                  },
                ),
                SizedBox(height: 20),
                _TextFieldCustom(
                  icono: Icons.person_outline,
                  type: TextInputType.text,
                  texto: 'Nombre del Empleado',
                  controller: TextEditingController(text: _nombreCompletoEmpleado),
                  readOnly: true,
                ),
                _TextFieldCustom(
                  icono: Icons.code,
                  type: TextInputType.text,
                  texto: 'Código del Producto',
                  controller: _codigoController,
                ),
                DropdownButtonFormField<String>(
                  value: _nombreProductoSeleccionado.isEmpty ? null : _nombreProductoSeleccionado,
                  decoration: InputDecoration(
                    labelText: 'Nombre del Producto',
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
                  items: _productosEstablecidos.values.map((producto) {
                    return DropdownMenuItem<String>(
                      value: producto['nombre'],
                      child: Text(producto['nombre']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _nombreProductoSeleccionado = value ?? '';
                      final codigoProducto = _productosEstablecidos.entries.firstWhere(
                        (element) => element.value['nombre'] == _nombreProductoSeleccionado,
                        orElse: () => MapEntry('', {'nombre': '', 'precio': 0.0}),
                      );
                      if (codigoProducto.key.isNotEmpty) {
                        _codigoController.text = codigoProducto.key;
                        _precioUnitarioController.text = codigoProducto.value['precio'].toString();
                      }
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, seleccione un producto';
                    }
                    return null;
                  },
                ),
                _TextFieldCustom(
                  icono: Icons.format_list_numbered,
                  type: TextInputType.number,
                  texto: 'Cantidad',
                  controller: _cantidadController,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                    FilteringTextInputFormatter.allow(RegExp(r'^[1-9]\d{0,2}$')),
                  ],
                ),
                _TextFieldCustom(
                  icono: Icons.monetization_on,
                  type: TextInputType.number,
                  texto: 'Precio Unitario',
                  controller: _precioUnitarioController,
                ),
                DropdownButtonFormField(
                  value: _metodoPagoController.text.isNotEmpty ? _metodoPagoController.text : null,
                  hint: Text('Seleccione Método de Pago', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  items: _metodoPagoMap.entries.map<DropdownMenuItem<String>>((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value, style: TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _metodoPagoController.text = value as String;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, seleccione un método de pago';
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _agregarProducto,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff5511b0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                      child: Text('Agregar Producto', style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _mostrarBottomSheet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff5511b0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                      child: Text('Ver productos', style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _guardarFactura,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff5511b0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: Text('Guardar Factura', style: TextStyle(color: Colors.white, fontSize: 18)),
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
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;

  const _TextFieldCustom({
    Key? key,
    required this.icono,
    required this.type,
    required this.texto,
    required this.controller,
    this.readOnly = false,
    this.inputFormatters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller,
        keyboardType: type,
        readOnly: readOnly,
        inputFormatters: inputFormatters,
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
