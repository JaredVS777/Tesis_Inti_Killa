import 'package:flutter/material.dart';
import 'package:proyecto/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'formulario_cliente_page.dart';
import 'login_page.dart';

class ClientePage extends StatefulWidget {
  @override
  _ClientePageState createState() => _ClientePageState();
}

class _ClientePageState extends State<ClientePage> {
  late Future<List<dynamic>> _clientesFuture;
  List<dynamic> _clientes = [];
  List<dynamic> _clientesFiltrados = [];
  TextEditingController _searchController = TextEditingController();

  final Map<String, String> _tipoDocMap = {
    '04': 'RUC',
    '05': 'CÉDULA',
    '06': 'PASAPORTE',
    '07': 'VENTA A CONSUMIDOR FINAL',
    '08': 'IDENTIFICACION DEL EXTERIOR'
  };

  @override
  void initState() {
    super.initState();
    _clientesFuture = _fetchClientes();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<List<dynamic>> _fetchClientes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      throw Exception('No se pudo obtener el token');
    }

    try {
      List<dynamic> clientes = await ApiService.fetchClientesFromApi(token);
      setState(() {
        _clientes = clientes;
        _clientesFiltrados = clientes;
      });
      return clientes;
    } catch (e) {
      print('Error al cargar los clientes: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los clientes: $e')),
      );
      return []; // Devolver una lista vacía en caso de error
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _clientesFiltrados = _clientes;
      } else {
        _clientesFiltrados = _clientes.where((cliente) {
          return cliente['cedula'].toString().contains(query);
        }).toList();
      }
    });
  }

  void _agregarCliente(Map<String, dynamic> cliente) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      throw Exception('No se pudo obtener el token');
    }

    try {
      var response = await ApiService.agregarCliente(token: token, cliente: cliente);
      var nuevoCliente = response['cliente'];
      print('Nuevo cliente: $nuevoCliente');  // Debugging
      setState(() {
        _clientes.insert(0, nuevoCliente); // Insertar el cliente al principio de la lista con el _id correcto
        _clientesFiltrados = _clientes;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cliente agregado correctamente')),
      );
    } catch (e) {
      print('Error al agregar el cliente: $e');
      String errorMessage = 'Error al agregar el cliente';
      if (e.toString().contains('400')) {
        errorMessage = 'La cédula ingresada ya está registrada';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  void _modificarCliente(Map<String, dynamic> clienteModificado, int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      throw Exception('No se pudo obtener el token');
    }

    try {
      var success = await ApiService.modificarCliente(
        token: token,
        id: clienteModificado['_id'].toString(),
        nombre: clienteModificado['nombre'],
        cedula: clienteModificado['cedula'],
        telefono: clienteModificado['telefono'],
        direccion: clienteModificado['direccion'],
        email: clienteModificado['email'],
        tipodoc: clienteModificado['tipodoc'],
      );
      if (success) {
        setState(() {
          _clientes[index] = clienteModificado;
          _clientesFiltrados = _clientes;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cliente modificado correctamente')),
        );
      } else {
        throw Exception('Error al modificar el cliente');
      }
    } catch (e) {
      print('Error al modificar el cliente: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al modificar el cliente: $e')),
      );
    }
  }

  void _eliminarCliente(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      throw Exception('No se pudo obtener el token');
    }

    final cliente = _clientes[index];
    final id = cliente['_id'];

    bool success = await ApiService.eliminarCliente(token: token, id: id);
    if (success) {
      setState(() {
        _clientes.removeAt(index);
        _clientesFiltrados = _clientes;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cliente eliminado correctamente')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el cliente')),
      );
    }
  }

  void _confirmarModificacionCliente(Map<String, dynamic> cliente, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Modificación'),
          content: Text('¿Seguro quieres modificar el cliente?'),
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
                _abrirFormularioCliente(cliente: cliente, index: index);
              },
              child: Text('Sí'),
            ),
          ],
        );
      },
    );
  }

  void _confirmarEliminacionCliente(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Eliminación'),
          content: Text('¿Seguro quieres eliminar el cliente?'),
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
                _eliminarCliente(index);
              },
              child: Text('Sí'),
            ),
          ],
        );
      },
    );
  }

  void _abrirFormularioCliente({Map<String, dynamic>? cliente, int? index}) async {
    final clienteModificado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormularioClientePage(cliente: cliente),
      ),
    );
    if (clienteModificado != null) {
      setState(() {
        if (index == null) {
          _clientes.insert(0, clienteModificado); // Insertar el cliente al principio de la lista
        } else {
          _clientes[index] = clienteModificado;
        }
        _clientesFiltrados = _clientes;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cliente guardado correctamente')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('CLIENTES', style: TextStyle(color: Colors.white))), // Título centrado y color blanco
        backgroundColor: Color(0xff5511b0), // Color de fondo del AppBar
        iconTheme: IconThemeData(color: Colors.white), // Color de las tres líneas del drawer
      ),
      backgroundColor: Color(0xFF0A192F), // Color de fondo
      drawer: _buildDrawer(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<dynamic>>(
          future: _clientesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error al cargar los clientes'));
            } else if (snapshot.hasData && snapshot.data!.isEmpty) {
              return Center(child: Text('No hay clientes disponibles'));
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 20),
                  TextField(
                    controller: _searchController,
                    style: TextStyle(color: Colors.black), // Cambiar el color del texto a negro
                    decoration: InputDecoration(
                      labelText: 'Buscar por cédula',
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
                      _abrirFormularioCliente();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff5511b0), // Color del botón
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      child: Text('+ Agregar clientes', style: TextStyle(fontSize: 16, color: Colors.white)), // Texto en color blanco
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _clientesFiltrados.length,
                      itemBuilder: (context, index) {
                        var cliente = _clientesFiltrados[index];
                        return _buildClienteCard(
                          cliente['_id'] ?? 'ID no disponible',
                          cliente['nombre'],
                          cliente['cedula'],
                          cliente['telefono'],
                          cliente['direccion'],
                          cliente['email'],
                          cliente['tipodoc'], // Pasa el valor del tipo de identificación directamente
                          index,
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          },
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

Widget _buildClienteCard(String id, String nombre, String cedula, String telefono, String direccion, String email, String tipodoc, int index) {
    final tipoDoc = _tipoDocMap[tipodoc] ?? 'Tipo de identificación no disponible';
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
              nombre,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            SizedBox(height: 10),
            _buildInfoRow('ID', id),
            _buildInfoRow('Cédula', cedula),
            _buildInfoRow('Teléfono', telefono),
            _buildInfoRow('Dirección', direccion),
            _buildInfoRow('Email', email),
            _buildInfoRow('Tipo de Identificación', tipoDoc),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    _confirmarModificacionCliente(_clientesFiltrados[index], index);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _confirmarEliminacionCliente(index);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
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
}
