import 'package:flutter/material.dart';
import 'verificacion_contrasena_page.dart'; // Importa la página de verificación

class RecuperacionContrasenaPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recuperación de Contraseña'),
        centerTitle: true,
      ),
      backgroundColor: Color(0xFF0A192F), // Color de fondo
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Correo Electrónico',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    final email = emailController.text;
                    // Aquí podrías agregar la lógica para enviar el correo de verificación
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => VerificacionContrasenaPage(email: email)),
                    );
                  },
                  child: Text('Siguiente'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
