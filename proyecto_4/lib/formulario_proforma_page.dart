import 'package:flutter/material.dart';
import 'api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormularioProformaPage extends StatefulWidget {
  @override
  _FormularioProformaPageState createState() => _FormularioProformaPageState();
}

class _FormularioProformaPageState extends State<FormularioProformaPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _precioUnitarioController = TextEditingController();
  final TextEditingController _totalDescuentoController = TextEditingController();
  final TextEditingController _idEmpleadoController = TextEditingController();

  String _idCliente = '';
  List<Map<String, dynamic>> _productos = [];
  double _totalSinImpuestos = 0.0;
  double _totalDescuento = 0.0;
  double _totalImpuestoValor = 0.0;
  double _importeTotal = 0.0;
  List<dynamic> _clientes = [];

  @override
  void initState() {
    super.initState();
    _fetchClientes();
    _setEmpleadoId();
    _totalDescuentoController.addListener(_actualizarTotales);
  }

  @override
  void dispose() {
    _totalDescuentoController.removeListener(_actualizarTotales);
    _totalDescuentoController.dispose();
    super.dispose();
  }

  Future<void> _fetchClientes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      List<dynamic> clientes = await ApiService.fetchClientes(token);
      setState(() {
        _clientes = clientes;
      });
    }
  }

  Future<void> _setEmpleadoId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? idEmpleado = prefs.getString('_id');  // Usamos '_id' ya que es el identificador del empleado

    if (idEmpleado != null) {
      setState(() {
        _idEmpleadoController.text = idEmpleado;  // Establecer el ID del empleado en el controlador del campo de texto
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
      _actualizarTotales(); // Actualizamos los totales cuando cambia el total sin impuestos
    });
  }

  void _actualizarTotales() {
    setState(() {
      _totalDescuento = double.tryParse(_totalDescuentoController.text) ?? 0.0;
      _totalImpuestoValor = _totalSinImpuestos * 0.15; // 15% de IVA
      _importeTotal = _totalSinImpuestos + _totalImpuestoValor - _totalDescuento;
    });
  }

  void _agregarProducto() {
    if (_codigoController.text.isNotEmpty &&
        _nombreController.text.isNotEmpty &&
        _cantidadController.text.isNotEmpty &&
        _precioUnitarioController.text.isNotEmpty) {
      setState(() {
        _productos.add({
          'codigo': _codigoController.text,
          'nombre': _nombreController.text,
          'cantidad': int.parse(_cantidadController.text),
          'precioUnitario': double.parse(_precioUnitarioController.text),
        });

        // Limpiar campos
        _codigoController.clear();
        _nombreController.clear();
        _cantidadController.clear();
        _precioUnitarioController.clear();

        // Calcular el total sin impuestos
        _calcularTotalSinImpuestos();
      });

      // Mostrar el BottomSheet con la tabla de productos y los campos adicionales
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
                                Navigator.pop(context); // Cerrar el BottomSheet
                                _mostrarBottomSheet(); // Volver a mostrar el BottomSheet actualizado
                              });
                            },
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Total sin Impuestos'),
                  keyboardType: TextInputType.number,
                  readOnly: true,
                  controller: TextEditingController(
                    text: _totalSinImpuestos.toStringAsFixed(2),
                  ),
                ),
                TextFormField(
                  controller: _totalDescuentoController,
                  decoration: InputDecoration(labelText: 'Total Descuento'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) {
                    _totalDescuento = double.tryParse(value ?? '0.0') ?? 0.0;
                    _actualizarTotales();
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese el total descuento';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Total Impuesto Valor'),
                  keyboardType: TextInputType.number,
                  readOnly: true,
                  controller: TextEditingController(
                    text: _totalImpuestoValor.toStringAsFixed(2),
                  ),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Importe Total'),
                  keyboardType: TextInputType.number,
                  readOnly: true,
                  controller: TextEditingController(
                    text: _importeTotal.toStringAsFixed(2),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Cerrar el BottomSheet
                    _guardarProforma();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff5511b0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: Text('Guardar Proforma', style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _guardarProforma() async {
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
        Map<String, dynamic> response = await ApiService.agregarProforma(
          token: token,
          idCliente: _idCliente,
          idEmpleado: _idEmpleadoController.text,
          productos: _productos,
          totalSinImpuestos: _totalSinImpuestos,
          totalDescuento: _totalDescuento,
          totalImpuestoValor: _totalImpuestoValor,
          importeTotal: _importeTotal,
        );

        if (response.containsKey('mensaje')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['mensaje'])),
          );
          Navigator.pop(context, true); // Volver y recargar la lista de proformas
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Proforma guardada con éxito')),
          );
          Navigator.pop(context, true); // Indicar que se guardó correctamente y recargar la lista
        }
      } catch (e) {
        print('Error al agregar la proforma: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar la proforma')),
        );
      }
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Formulario de Proformas'),
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
                DropdownButtonFormField(
                  decoration: InputDecoration(
                    labelText: 'ID Cliente',
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
                  value: _idCliente.isNotEmpty ? _idCliente : null,
                  items: _clientes.map<DropdownMenuItem<String>>((cliente) {
                    return DropdownMenuItem<String>(
                      value: cliente['_id'],
                      child: Text(cliente['_id'], style: TextStyle(color: Colors.black)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _idCliente = value as String;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, seleccione un cliente';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                _TextFieldCustom(
                  icono: Icons.person_outline,
                  type: TextInputType.text,
                  texto: 'ID Empleado',
                  controller: _idEmpleadoController,
                  readOnly: true,
                ),
                _TextFieldCustom(
                  icono: Icons.code,
                  type: TextInputType.text,
                  texto: 'Código del Producto',
                  controller: _codigoController,
                ),
                _TextFieldCustom(
                  icono: Icons.description,
                  type: TextInputType.text,
                  texto: 'Nombre del Producto',
                  controller: _nombreController,
                ),
                _TextFieldCustom(
                  icono: Icons.format_list_numbered,
                  type: TextInputType.number,
                  texto: 'Cantidad',
                  controller: _cantidadController,
                ),
                _TextFieldCustom(
                  icono: Icons.monetization_on,
                  type: TextInputType.number,
                  texto: 'Precio Unitario',
                  controller: _precioUnitarioController,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _agregarProducto,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff5511b0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: Text('Agregar Producto', style: TextStyle(color: Colors.white, fontSize: 18)),
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

  const _TextFieldCustom({
    Key? key,
    required this.icono,
    required this.type,
    required this.texto,
    required this.controller,
    this.readOnly = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller,
        keyboardType: type,
        readOnly: readOnly,
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
