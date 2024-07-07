import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _nombreUsuario = 'Usuario';

  @override
  void initState() {
    super.initState();
    _cargarNombreUsuario();
  }

  Future<void> _cargarNombreUsuario() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? nombre = prefs.getString('nombre');
    if (nombre != null) {
      setState(() {
        _nombreUsuario = nombre;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color(0xff5511b0),
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(50),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 50),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 30),
                  title: Text('Bienvenido $_nombreUsuario!', style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold
                  )),
                  subtitle: Text('¿Qué deseas gestionar hoy?', style: TextStyle(
                      color: Colors.white,
                      fontSize: 16
                  )),
                  trailing: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Text(
                      _nombreUsuario[0], // Muestra la inicial del nombre
                      style: TextStyle(fontSize: 30.0, color: Color(0xff5511b0)),
                    ),
                  ),
                ),
                const SizedBox(height: 30)
              ],
            ),
          ),
          Container(
            color: Color(0xff5511b0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 90),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(200)
                )
              ),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  itemDashboard('Clientes', Icons.person, Color(0xFFBB6464), context, '/cliente'),
                  itemDashboard('Factura', Icons.receipt, Color(0xFFE6B566), context, '/factura'),
                  itemDashboard('Proforma', Icons.description, Color(0xFF8FE3CF), context, '/proforma'),
                  itemDashboard('Cerrar sesión', Icons.logout, Colors.red, context, '/login', logout: true),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20)
        ],
      ),
    );
  }

  Widget itemDashboard(String title, IconData iconData, Color background, BuildContext context, String route, {bool logout = false}) => GestureDetector(
    onTap: () {
      if (logout) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
      } else {
        Navigator.pushNamed(context, route);
      }
    },
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 5),
            color: Theme.of(context).primaryColor.withOpacity(.2),
            spreadRadius: 2,
            blurRadius: 5
          )
        ]
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 8),
          Text(title.toUpperCase(), style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          )),
        ],
      ),
    ),
  );
}
