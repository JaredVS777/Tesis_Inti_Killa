import 'package:flutter/material.dart';
import 'login_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HOME', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Color(0xFF0A192F),
      ),
      backgroundColor: Color(0xFF0A192F), // Mismo color de fondo que el login
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Botón de Clientes
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/cliente');
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(16.0),
                backgroundColor: Color(0xFFBB6464),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: Icon(Icons.person, size: 24.0),
              label: Text(
                'CLIENTES',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            SizedBox(height: 20),
            // Fila que contiene los botones de Factura y Proforma
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/factura');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(16.0),
                      backgroundColor: Color(0xFFE6B566),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: Icon(Icons.receipt, size: 24.0),
                    label: Text(
                      'FACTURA',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/proforma');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(16.0),
                      backgroundColor: Color(0xFF8FE3CF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: Icon(Icons.description, size: 24.0),
                    label: Text(
                      'PROFORMA',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
            // Botón de Cerrar sesión
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: Icon(Icons.logout, size: 24.0, color: Colors.white),
              label: Text(
                'Cerrar sesión',
                style: TextStyle(fontSize: 18.0, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
