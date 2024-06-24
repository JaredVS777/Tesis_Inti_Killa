import 'package:flutter/material.dart';
import 'api_service.dart';
import 'proforma_page.dart';
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

  String _idCliente = '';
  String _idEmpleado = '';
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
    String? idEmpleado = prefs.getString('idEmpleado');

    if (idEmpleado != null) {
      setState(() {
        _idEmpleado = idEmpleado;
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
    }
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
            idEmpleado: _idEmpleado,
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
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al guardar la proforma')),
            );
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              DropdownButtonFormField(
                decoration: InputDecoration(labelText: 'ID Cliente'),
                value: _idCliente.isNotEmpty ? _idCliente : null,
                items: _clientes.map<DropdownMenuItem<String>>((cliente) {
                  return DropdownMenuItem<String>(
                    value: cliente['_id'],
                    child: Text(cliente['_id']),
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
              TextFormField(
                decoration: InputDecoration(labelText: 'ID Empleado'),
                initialValue: _idEmpleado,
                onChanged: (value) {
                  setState(() {
                    _idEmpleado = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el ID del empleado';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _codigoController,
                decoration: InputDecoration(labelText: 'Código del Producto'),
              ),
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'Nombre del Producto'),
              ),
              TextFormField(
                controller: _cantidadController,
                decoration: InputDecoration(labelText: 'Cantidad'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _precioUnitarioController,
                decoration: InputDecoration(labelText: 'Precio Unitario'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _agregarProducto,
                child: Text('Agregar Producto'),
              ),
              SizedBox(height: 20),
              DataTable(
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
                          });
                        },
                      ),
                    ),
                  ]);
                }).toList(),
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
                onPressed: _guardarProforma,
                child: Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
