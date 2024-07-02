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

  Future<void> _enviarSRI(String claveAcceso) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      bool success = await ApiService.enviarSRI(token, claveAcceso);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Factura enviada al SRI correctamente')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar la factura al SRI')),
        );
      }
    }
  }

  Future<void> _autorizarSRI(String claveAcceso) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      bool success = await ApiService.autorizarSRI(token, claveAcceso);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Factura autorizada correctamente')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al autorizar la factura')),
        );
      }
    }
  }

  String _getCedulaCliente(String idCliente) {
    final cliente = _clientes.firstWhere((cliente) => cliente['id'] == idCliente, orElse: () => {'cedula': 'N/A'});
    return cliente['cedula'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('FACTURAS', style: TextStyle(color: Colors.white))), // Título centrado y color blanco
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
                  return Card(
                    color: Colors.white, // Fondo de la tarjeta
                    margin: EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Cédula Cliente: ${_getCedulaCliente(factura['id_cliente'])}', style: TextStyle(color: Colors.black)),
                          Text('ID Empleado: ${factura['id_empleado']}', style: TextStyle(color: Colors.black)),
                          Text('Productos:', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          ..._buildProductList(factura['productos']),
                          Text('Total sin Impuestos: ${factura['totalSinImpuestos']}', style: TextStyle(color: Colors.black)),
                          Text('Total Descuento: ${factura['totalDescuento']}', style: TextStyle(color: Colors.black)),
                          Text('Total Impuesto Valor: ${factura['totalImpuestoValor']}', style: TextStyle(color: Colors.black)),
                          Text('Importe Total: ${factura['importeTotal']}', style: TextStyle(color: Colors.black)),
                          Text('Método de Pago: ${_metodoPagoMap[factura['formaPago']] ?? 'Método no disponible'}', style: TextStyle(color: Colors.black)),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () => _enviarSRI(factura['claveAcceso']),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                child: Text('ENVIAR SRI', style: TextStyle(color: Colors.white)),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () => _autorizarSRI(factura['claveAcceso']),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
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
              ),
            ),
          ],
        ),
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
            Text('Código: ${producto['codigo']}', style: TextStyle(color: Colors.black)),
            Text('Nombre: ${producto['nombre']}', style: TextStyle(color: Colors.black)),
            Text('Cantidad: ${producto['cantidad']}', style: TextStyle(color: Colors.black)),
            Text('Precio Unitario: ${producto['precioUnitario']}', style: TextStyle(color: Colors.black)),
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
