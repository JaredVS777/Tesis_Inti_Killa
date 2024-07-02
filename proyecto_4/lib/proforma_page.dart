import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'login_page.dart';
import 'formulario_proforma_page.dart';

class ProformaPage extends StatefulWidget {
  @override
  _ProformaPageState createState() => _ProformaPageState();
}

class _ProformaPageState extends State<ProformaPage> {
  List<dynamic> _proformas = [];
  List<dynamic> _proformasFiltradas = [];
  List<Map<String, dynamic>> _clientes = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProformas();
    _fetchClientes();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchProformas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      List<dynamic> proformas = await ApiService.fetchProformas(token);
      setState(() {
        _proformas = proformas;
        _proformasFiltradas = proformas;
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
        _proformasFiltradas = _proformas;
      } else {
        _proformasFiltradas = _proformas.where((proforma) {
          final cliente = _clientes.firstWhere((cliente) => cliente['id'] == proforma['id_cliente'], orElse: () => {'cedula': ''});
          return cliente['cedula'].toString().contains(query);
        }).toList();
      }
    });
  }

  Future<void> _navegarAFormularioProforma({Map<String, dynamic>? proforma, int? index}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormularioProformaPage(proforma: proforma),
      ),
    );

    if (result == true) {
      _fetchProformas();
    }
  }

  void _confirmarModificacionProforma(Map<String, dynamic> proforma, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Modificación'),
          content: Text('¿Seguro quieres modificar la proforma?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navegarAFormularioProforma(proforma: proforma, index: index);
              },
              child: Text('Sí'),
            ),
          ],
        );
      },
    );
  }

  String _getCedulaCliente(String idCliente) {
    final cliente = _clientes.firstWhere((cliente) => cliente['id'] == idCliente, orElse: () => {'cedula': 'N/A'});
    return cliente['cedula'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('PROFORMAS', style: TextStyle(color: Colors.white))), // Título centrado y color blanco
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
              onPressed: () {
                _navegarAFormularioProforma();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff5511b0), // Color del botón
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Text('+ Agregar Proforma', style: TextStyle(fontSize: 16, color: Colors.white)), // Texto en color blanco
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _proformasFiltradas.length,
                itemBuilder: (context, index) {
                  var proforma = _proformasFiltradas[index];
                  return Card(
                    color: Colors.white, // Fondo de la tarjeta
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ListTile(
                      title: Text('Cédula Cliente: ${_getCedulaCliente(proforma['id_cliente'])}', style: TextStyle(color: Colors.black)), // Texto en negro
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ID Empleado: ${proforma['id_empleado']}', style: TextStyle(color: Colors.black)),
                          Text('Productos:', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          ..._buildProductList(proforma['productos']),
                          Text('Total sin Impuestos: ${proforma['totalSinImpuestos']}', style: TextStyle(color: Colors.black)),
                          Text('Total Descuento: ${proforma['totalDescuento']}', style: TextStyle(color: Colors.black)),
                          Text('Total Impuesto Valor: ${proforma['totalImpuestoValor']}', style: TextStyle(color: Colors.black)),
                          Text('Importe Total: ${proforma['importeTotal']}', style: TextStyle(color: Colors.black)),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.edit, color: Colors.black),
                        onPressed: () {
                          _confirmarModificacionProforma(proforma, index);
                        },
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
