import 'package:flutter/material.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'cliente_page.dart';
import 'factura_page.dart';
import 'proforma_page.dart';
import 'recuperacion_usuario_page.dart'; // Importa la nueva página
import 'recuperacion_contrasena_page.dart'; // Importa la página de recuperación de contraseña
import 'verificacion_contrasena_page.dart'; // Importa la página de verificación de contraseña

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login', // Ruta inicial al iniciar la aplicación
      routes: {
        '/login': (context) => LoginPage(), // Ruta para la página de inicio de sesión
        '/home': (context) => HomePage(),   // Ruta para la página de inicio
        '/cliente': (context) => ClientePage(), // Ruta para la página de clientes
        '/factura': (context) => FacturaPage(), // Ruta para la página de facturas
        '/proforma': (context) => ProformaPage(), // Ruta para la página de proformas
        '/recuperacion_usuario': (context) => RecuperacionUsuarioPage(), // Nueva ruta
        '/recuperacion_contrasena': (context) => RecuperacionContrasenaPage(), // Ruta para recuperación de contraseña
        '/verificacion_contrasena': (context) => VerificacionContrasenaPage(email: ''), // Ruta para verificación de contraseña
      },
    );
  }
}
