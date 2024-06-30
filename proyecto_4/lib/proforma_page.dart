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

  @override
  void initState() {
    super.initState();
    _fetchProformas();
  }

  Future<void> _fetchProformas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    
    if (token != null) {
      List<dynamic> proformas = await ApiService.fetchProformas(token);
      setState(() {
        _proformas = proformas;
      });
    }
  }

  Future<void> _navegarAFormularioProforma() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FormularioProformaPage()),
    );

    if (result == true) {
      _fetchProformas();
    }
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
            ElevatedButton(
              onPressed: _navegarAFormularioProforma,
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
                itemCount: _proformas.length,
                itemBuilder: (context, index) {
                  var proforma = _proformas[index];
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
                          Text('ID Cliente: ${proforma['id_cliente']}', style: TextStyle(color: Colors.black)),
                          Text('ID Empleado: ${proforma['id_empleado']}', style: TextStyle(color: Colors.black)),
                          Text('Productos:', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          ..._buildProductList(proforma['productos']),
                          Text('Total sin Impuestos: ${proforma['totalSinImpuestos']}', style: TextStyle(color: Colors.black)),
                          Text('Total Descuento: ${proforma['totalDescuento']}', style: TextStyle(color: Colors.black)),
                          Text('Total Impuesto Valor: ${proforma['totalImpuestoValor']}', style: TextStyle(color: Colors.black)),
                          Text('Importe Total: ${proforma['importeTotal']}', style: TextStyle(color: Colors.black)),
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
