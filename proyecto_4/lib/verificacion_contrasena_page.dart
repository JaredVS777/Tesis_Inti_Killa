import 'package:flutter/material.dart';
import 'login_page.dart';

class VerificacionContrasenaPage extends StatelessWidget {
  final String email;
  final TextEditingController verificationCodeController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController = TextEditingController();

  VerificacionContrasenaPage({required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verificación de Contraseña'),
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
                  controller: verificationCodeController,
                  decoration: InputDecoration(
                    labelText: 'Código de Verificación',
                    prefixIcon: Icon(Icons.verified),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Nueva Contraseña',
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: confirmNewPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirmar Nueva Contraseña',
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Aquí podrías agregar la lógica para verificar el código y establecer la nueva contraseña
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
