import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'login_page.dart';
import 'formulario_factura_page.dart';

class FacturaPage extends StatefulWidget {
  @override
  _FacturaPageState createState() => _FacturaPageState();
}

class _FacturaPageState extends State<FacturaPage> {
  List<dynamic> _facturas = [];

  @override
  void initState() {
    super.initState();
    _fetchFacturas();
  }

  Future<void> _fetchFacturas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      List<dynamic> facturas = await ApiService.fetchFacturas(token);
      setState(() {
        _facturas = facturas;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('FACTURAS')),
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
              onPressed: _navegarAFormularioFactura,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Text('+ Agregar Factura', style: TextStyle(fontSize: 16)),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _facturas.length,
                itemBuilder: (context, index) {
                  var factura = _facturas[index];
                  return Card(
                    margin: EdgeInsets.all(10),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ID Cliente: ${factura['id_cliente']}'),
                          Text('ID Empleado: ${factura['id_empleado']}'),
                          Text('Productos: ${factura['productos']}'),
                          Text('Total sin Impuestos: ${factura['totalSinImpuestos']}'),
                          Text('Total Descuento: ${factura['totalDescuento']}'),
                          Text('Total Impuesto Valor: ${factura['totalImpuestoValor']}'),
                          Text('Importe Total: ${factura['importeTotal']}'),
                          Text('Método de Pago: ${factura['formaPago']}'),
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
