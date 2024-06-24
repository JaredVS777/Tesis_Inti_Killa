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
        title: Center(child: Text('PROFORMAS')),
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
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Text('+ Agregar proformas', style: TextStyle(fontSize: 16)),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _proformas.length,
                itemBuilder: (context, index) {
                  var proforma = _proformas[index];
                  return Card(
                    margin: EdgeInsets.all(10),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ID Cliente: ${proforma['id_cliente']}'),
                          Text('ID Empleado: ${proforma['id_empleado']}'),
                          Text('Productos: ${proforma['products']}'),
                          Text('Total sin Impuestos: ${proforma['totalSinImpuestos']}'),
                          Text('Total Descuento: ${proforma['totalDescuento']}'),
                          Text('Total Impuesto Valor: ${proforma['totalImpuestoValor']}'),
                          Text('Importe Total: ${proforma['importeTotal']}'),
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
        final username = prefs.getString('username') ?? 'Usuario';

        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text(username),
                accountEmail: Text('USUARIO'),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    username[0],
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