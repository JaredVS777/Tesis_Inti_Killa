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
          _Titulo(), // Añadido el título aquí
          SizedBox(height: 20),
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

class _BottonSignIn extends StatefulWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;

  _BottonSignIn({required this.usernameController, required this.passwordController});

  @override
  __BottonSignInState createState() => __BottonSignInState();
}

class __BottonSignInState extends State<_BottonSignIn> {
  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 10),
              Text('Error'),
            ],
          ),
          content: Text('ERROR AL INICIO DE SESION, VERIFIQUE EL USUARIO Y CONTRASEÑA'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

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
          final username = widget.usernameController.text;
          final password = widget.passwordController.text;
          final success = await ApiService.login(username, password); // Cambiar aquí para usar el nombre de usuario
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Inicio de sesión exitoso'),
            ));
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            _showErrorDialog(context); // Mostrar el diálogo de error
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

class _UsernameAndPassword extends StatefulWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;

  _UsernameAndPassword({required this.usernameController, required this.passwordController});

  @override
  __UsernameAndPasswordState createState() => __UsernameAndPasswordState();
}

class __UsernameAndPasswordState extends State<_UsernameAndPassword> {
  bool _obscureText = true;
  final int _maxUsernameLength = 15;
  final int _maxPasswordLength = 20;

  void _togglePasswordView() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _showMaxLengthWarning(BuildContext context, String field, int maxLength) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Se permite hasta $maxLength caracteres en el campo $field'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          TextField(
            controller: widget.usernameController,
            keyboardType: TextInputType.text,
            maxLength: _maxUsernameLength,
            decoration: InputDecoration(
              hintText: 'Usuario',
              filled: true,
              fillColor: Color(0xffEBDCFA),
              prefixIcon: Icon(Icons.person_outline, color: Colors.grey),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xffEBDCFA)),
                borderRadius: BorderRadius.circular(50),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xffEBDCFA)),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            onChanged: (value) {
              if (value.length > _maxUsernameLength) {
                widget.usernameController.text = value.substring(0, _maxUsernameLength);
                widget.usernameController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _maxUsernameLength),
                );
                _showMaxLengthWarning(context, 'Usuario', _maxUsernameLength);
              }
            },
          ),
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
          TextField(
            controller: widget.passwordController,
            keyboardType: TextInputType.text,
            obscureText: _obscureText,
            maxLength: _maxPasswordLength,
            decoration: InputDecoration(
              hintText: 'Contraseña',
              filled: true,
              fillColor: Color(0xffEBDCFA),
              prefixIcon: Icon(Icons.lock, color: Colors.grey),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xffEBDCFA)),
                borderRadius: BorderRadius.circular(50),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xffEBDCFA)),
                borderRadius: BorderRadius.circular(50),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: _togglePasswordView,
              ),
            ),
            onChanged: (value) {
              if (value.length > _maxPasswordLength) {
                widget.passwordController.text = value.substring(0, _maxPasswordLength);
                widget.passwordController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _maxPasswordLength),
                );
                _showMaxLengthWarning(context, 'Contraseña', _maxPasswordLength);
              }
            },
          ),
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
        height: 120,
        width: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(blurRadius: 10, color: Colors.black26),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/images/logo.png', // Asegúrate de que esta ruta sea correcta
            fit: BoxFit.cover,
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

class _Titulo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        children: [
          Text(
            'Iniciar sesión',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
