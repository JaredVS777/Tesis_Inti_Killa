import 'package:flutter/material.dart';
import 'api_service.dart';
import 'home_page.dart';
import 'recuperacion_usuario_page.dart'; // Importa la nueva página
import 'recuperacion_contrasena_page.dart'; // Importa la página de recuperación de contraseña

class LoginPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A192F), // Color de fondo cambiado
      body: ListView(
        padding: EdgeInsets.only(top: 0),
        physics: BouncingScrollPhysics(),
        children: [
          Stack(
            children: [
              _HeaderLogin(),
              _LogoHeader(),
            ],
          ),
          SizedBox(height: 40),
          _UsernameAndPassword(
            usernameController: usernameController,
            passwordController: passwordController,
          ),
          SizedBox(height: 40),
          _BottonSignIn(usernameController: usernameController, passwordController: passwordController),
        ],
      ),
    );
  }
}

class _BottonSignIn extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;

  _BottonSignIn({required this.usernameController, required this.passwordController});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Color(0xff5511b0),
        borderRadius: BorderRadius.circular(50),
      ),
      child: TextButton(
        child: const Text(
          'Iniciar sesión',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        onPressed: () async {
          final username = usernameController.text;
          final password = passwordController.text;
          final success = await ApiService.login(username, password); // Cambiar aquí para usar el nombre de usuario
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Inicio de sesión exitoso'),
            ));
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Error en el inicio de sesión'),
            ));
          }
        },
      ),
    );
  }
}

class _ForgotPassword extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class _UsernameAndPassword extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;

  _UsernameAndPassword({required this.usernameController, required this.passwordController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          _TextFieldCustom(icono: Icons.person_outline, type: TextInputType.text, texto: 'Usuario', controller: usernameController),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RecuperacionUsuarioPage()),
                );
              },
              child: Text(
                '¿Olvidaste el usuario?',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _TextFieldCustom(icono: Icons.lock, type: TextInputType.text, pass: true, texto: 'Contraseña', controller: passwordController),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RecuperacionContrasenaPage()),
                );
              },
              child: Text(
                '¿Olvidaste la contraseña?',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TextFieldCustom extends StatelessWidget {
  final IconData icono;
  final TextInputType type;
  final bool pass;
  final String texto;
  final TextEditingController controller;

  const _TextFieldCustom({
    Key? key,
    required this.icono,
    required this.type,
    this.pass = false,
    required this.texto,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: type,
      obscureText: pass,
      decoration: InputDecoration(
        hintText: texto,
        filled: true,
        fillColor: Color(0xffEBDCFA),
        prefixIcon: Icon(icono, color: Colors.grey),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xffEBDCFA)),
          borderRadius: BorderRadius.circular(50),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xffEBDCFA)),
          borderRadius: BorderRadius.circular(50),
        ),
      ),
    );
  }
}

class _LogoHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 80,
      left: MediaQuery.of(context).size.width * 0.38,
      child: Container(
        height: 80,
        width: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(blurRadius: 10, color: Colors.black26),
          ],
        ),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            'FRAVE',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: Color(0xff5511b0)),
          ),
        ),
      ),
    );
  }
}

class _HeaderLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      child: CustomPaint(
        painter: _HeaderLoginPainter(),
      ),
    );
  }
}

class _HeaderLoginPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = Color(0xff5511b0);
    paint.style = PaintingStyle.fill;

    final path = Path();
    path.lineTo(0, size.height * 1.0);
    path.lineTo(size.width * 0.2, size.height * 0.8);
    path.lineTo(size.width, size.height * 1.0);
    path.lineTo(size.width, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
