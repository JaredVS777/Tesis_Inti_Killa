import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'formulario_factura_page.dart';
import 'login_page.dart';

class FacturaPage extends StatefulWidget {
  @override
  _FacturaPageState createState() => _FacturaPageState();
}

class _FacturaPageState extends State<FacturaPage> {
  List<dynamic> _facturas = [];
  List<dynamic> _facturasFiltradas = [];
  List<Map<String, dynamic>> _clientes = [];
  List<Map<String, dynamic>> _empleados = [];
  TextEditingController _searchController = TextEditingController();

  final Map<String, String> _metodoPagoMap = {
    '01': 'SIN UTILIZACION DEL SISTEMA FINANCIERO',
    '15': 'COMPENSACION DE DEUDAS',
    '16': 'TARJETA DE DEBITO',
    '17': 'DINERO ELECTRONICO',
    '18': 'TARJETA PREPAGO',
    '19': 'TARJETA DE CREDITO',
    '20': 'OTROS CON UTILIZACION DEL SISTEMA FINANCIERO',
    '21': 'ENDOSO DE TÍTULOS',
  };

  @override
  void initState() {
    super.initState();
    _fetchFacturas();
    _fetchClientes();
    _fetchEmpleados();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchFacturas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      List<dynamic> facturas = await ApiService.fetchFacturas(token);
      setState(() {
        _facturas = facturas;
        _facturasFiltradas = facturas;
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
            'cedula': cliente['cedula'],
            'nombre': cliente['nombre'],
          };
        }).toList();
      });
    }
  }

  Future<void> _fetchEmpleados() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      List<dynamic> empleados = await ApiService.fetchEmpleados(token);
      setState(() {
        _empleados = empleados.map((empleado) {
          return {
            'id': empleado['_id'],
            'nombreCompleto': '${empleado['nombre']} ${empleado['apellido']}',
          };
        }).toList();
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _facturasFiltradas = _facturas;
      } else {
        _facturasFiltradas = _facturas.where((factura) {
          final cliente = _clientes.firstWhere((cliente) => cliente['id'] == factura['id_cliente'], orElse: () => {'cedula': ''});
          return cliente['cedula'].toString().contains(query);
        }).toList();
      }
    });
  }

  Future<void> _navegarAFormularioFactura() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FormularioFacturaPage()),
    );

    if (result == true) {
      _fetchFacturas();
    }
  }

  Future<void> _enviarSRI(String claveAcceso, int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      var response = await ApiService.enviarSRI(token, claveAcceso);
      if (response['success']) {
        setState(() {
          _facturasFiltradas[index]['enviadoSRI'] = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Factura enviada al SRI correctamente')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
      }
    }
  }

  Future<void> _autorizarSRI(String claveAcceso, int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      var response = await ApiService.autorizarSRI(token, claveAcceso);
      if (response['success']) {
        setState(() {
          _facturasFiltradas[index]['autorizadoSRI'] = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Factura autorizada correctamente')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
      }
    }
  }

  String _getCedulaCliente(String idCliente) {
    final cliente = _clientes.firstWhere((cliente) => cliente['id'] == idCliente, orElse: () => {'cedula': 'N/A'});
    return cliente['cedula'];
  }

  String _getNombreCliente(String idCliente) {
    final cliente = _clientes.firstWhere((cliente) => cliente['id'] == idCliente, orElse: () => {'nombre': 'N/A'});
    return cliente['nombre'];
  }

  String _getNombreCompletoEmpleado(String idEmpleado) {
    final empleado = _empleados.firstWhere((empleado) => empleado['id'] == idEmpleado, orElse: () => {'nombreCompleto': 'N/A'});
    return empleado['nombreCompleto'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('FACTURAS', style: TextStyle(color: Colors.white)),
        ), // Título centrado y color blanco
        backgroundColor: Color(0xff5511b0), // Color de fondo del AppBar
        iconTheme: IconThemeData(color: Colors.white), // Color de las tres líneas del drawer
      ),
      backgroundColor: Color(0xFF0A192F),
      drawer: _buildDrawer(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),
            TextField(
              controller: _searchController,
              style: TextStyle(color: Colors.black), // Cambiar el color del texto a negro
              decoration: InputDecoration(
                labelText: 'Buscar por cédula del Cliente',
                labelStyle: TextStyle(color: Colors.black),
                filled: true,
                fillColor: Colors.white, // Fondo del campo de búsqueda
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.black),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _navegarAFormularioFactura,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff5511b0), // Color del botón
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Text('+ Agregar Factura', style: TextStyle(fontSize: 16, color: Colors.white)), // Texto en color blanco
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _facturasFiltradas.length,
                itemBuilder: (context, index) {
                  var factura = _facturasFiltradas[index];
                  return _buildFacturaCard(
                    factura['id_cliente'],
                    factura['id_empleado'],
                    factura['productos'],
                    factura['totalSinImpuestos'].toString(),
                    factura['totalDescuento'].toString(),
                    factura['totalImpuestoValor'].toString(),
                    factura['importeTotal'].toString(),
                    _metodoPagoMap[factura['formaPago']] ?? 'Método no disponible',
                    factura['claveAcceso'],
                    index,
                    factura['enviadoSRI'] ?? false,
                    factura['autorizadoSRI'] ?? false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacturaCard(
  String idCliente,
  String idEmpleado,
  List<dynamic> productos,
  String totalSinImpuestos,
  String totalDescuento,
  String totalImpuestoValor,
  String importeTotal,
  String formaPago,
  String claveAcceso,
  int index,
  bool enviadoSRI,
  bool autorizadoSRI,
) {
  bool isExpanded = false;
  return StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      return Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        shadowColor: Colors.black54,
        margin: EdgeInsets.all(10),
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cédula Cliente: ${_getCedulaCliente(idCliente)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              SizedBox(height: 5),
              Text(
                'Nombre Cliente: ${_getNombreCliente(idCliente)}',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              SizedBox(height: 10),
              _buildInfoRow('Empleado', _getNombreCompletoEmpleado(idEmpleado)),
              if (isExpanded) ...[
                Text(
                  'Productos:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                ..._buildProductList(productos),
                _buildInfoRow('Total sin Impuestos', totalSinImpuestos),
                _buildInfoRow('Total Descuento', totalDescuento),
                _buildInfoRow('Total Impuesto Valor', totalImpuestoValor),
                _buildInfoRow('Importe Total', importeTotal),
                _buildInfoRow('Método de Pago', formaPago),
              ],
              TextButton(
                onPressed: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Text(isExpanded ? 'Ver menos...' : 'Ver más...'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: enviadoSRI ? null : () => _enviarSRI(claveAcceso, index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: enviadoSRI ? Colors.grey : Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text('ENVIAR SRI', style: TextStyle(color: Colors.white)),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: autorizadoSRI ? null : (enviadoSRI ? () => _autorizarSRI(claveAcceso, index) : null),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: autorizadoSRI ? Colors.grey : (enviadoSRI ? Colors.green : Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text('AUTORIZAR', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}


  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildProductList(List<dynamic> productos) {
    return productos.map((producto) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Código', producto['codigo']),
            _buildInfoRow('Nombre', producto['nombre']),
            _buildInfoRow('Cantidad', producto['cantidad'].toString()),
            _buildInfoRow('Precio Unitario', producto['precioUnitario'].toString()),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildDrawer(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        } else {
          final prefs = snapshot.data!;
          final nombre = prefs.getString('nombre') ?? 'Usuario';
          final apellido = prefs.getString('apellido') ?? '';

          return Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                UserAccountsDrawerHeader(
                  accountName: Text('$nombre $apellido'),
                  accountEmail: Text('USUARIO'),
                  decoration: BoxDecoration(
                    color: Color(0xff5511b0),
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      nombre.isNotEmpty ? nombre[0] : 'U',
                      style: TextStyle(fontSize: 40.0),
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Clientes'),
                  onTap: () {
                    Navigator.pushNamed(context, '/cliente');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.description),
                  title: Text('Proformas'),
                  onTap: () {
                    Navigator.pushNamed(context, '/proforma');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.receipt),
                  title: Text('Facturas'),
                  onTap: () {
                    Navigator.pushNamed(context, '/factura');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Cerrar sesión'),
                  onTap: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.remove('token');
                    await prefs.remove('nombre');
                    await prefs.remove('apellido');
                    await prefs.remove('username');
                    await prefs.remove('_id');
                    await prefs.remove('email');
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
