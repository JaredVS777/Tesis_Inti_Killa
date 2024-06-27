import 'package:flutter/material.dart';
import 'api_service.dart';
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
      backgroundColor: Color(0xFF0A192F),
      body: ListView(
        padding: EdgeInsets.only(top: 0),
        physics: BouncingScrollPhysics(),
        children: [
          Stack(
            children: [
              _HeaderRecuperacion(),
              _BackButton(),
              _LogoHeader(),
            ],
          ),
          _Titulo(),
          SizedBox(height: 40),
          _VerificationFields(
            verificationCodeController: verificationCodeController,
            newPasswordController: newPasswordController,
            confirmNewPasswordController: confirmNewPasswordController,
          ),
          SizedBox(height: 40),
          _BottonRecuperar(
            verificationCodeController: verificationCodeController,
            newPasswordController: newPasswordController,
            confirmNewPasswordController: confirmNewPasswordController,
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      left: 10,
      child: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _BottonRecuperar extends StatelessWidget {
  final TextEditingController verificationCodeController;
  final TextEditingController newPasswordController;
  final TextEditingController confirmNewPasswordController;

  _BottonRecuperar({
    required this.verificationCodeController,
    required this.newPasswordController,
    required this.confirmNewPasswordController,
  });

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
          'Continuar',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        onPressed: () async {
          final token = verificationCodeController.text;
          final newPassword = newPasswordController.text;
          final confirmNewPassword = confirmNewPasswordController.text;

          final success = await ApiService.verificarCodigoYActualizarPassword(token, newPassword, confirmNewPassword);
          if (success) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Error al actualizar la contraseña'),
            ));
          }
        },
      ),
    );
  }
}

class _VerificationFields extends StatelessWidget {
  final TextEditingController verificationCodeController;
  final TextEditingController newPasswordController;
  final TextEditingController confirmNewPasswordController;

  _VerificationFields({
    required this.verificationCodeController,
    required this.newPasswordController,
    required this.confirmNewPasswordController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          _TextFieldCustom(icono: Icons.verified, type: TextInputType.text, texto: 'Código de Verificación', controller: verificationCodeController),
          SizedBox(height: 10),
          _TextFieldCustom(icono: Icons.lock, type: TextInputType.text, pass: true, texto: 'Nueva Contraseña', controller: newPasswordController),
          SizedBox(height: 10),
          _TextFieldCustom(icono: Icons.lock, type: TextInputType.text, pass: true, texto: 'Confirmar Nueva Contraseña', controller: confirmNewPasswordController),
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

class _HeaderRecuperacion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      child: CustomPaint(
        painter: _HeaderRecuperacionPainter(),
      ),
    );
  }
}

class _HeaderRecuperacionPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = Color(0xff5511b0);
    paint.style = PaintingStyle.fill;

    final path = Path();
    path.lineTo(0, size.height * 1.0);
    path.lineTo(size.width * 0.8, size.height * 0.8);
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
            'Verificación de Contraseña',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
