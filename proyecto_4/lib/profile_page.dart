import 'package:flutter/material.dart';
import 'api_service.dart';

class ProfilePage extends StatefulWidget {
  final String token; // Agrega el parámetro token

  ProfilePage({Key? key, required this.token}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> profileData = {};

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    try {
      final data = await ApiService.fetchProfile(widget.token); // Usa widget.token aquí
      setState(() {
        profileData = data;
      });
    } catch (e) {
      print('Error al cargar datos del perfil: $e');
      // Manejar el error de carga de datos del perfil
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Perfil')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: profileData.isEmpty
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nombre: ${profileData['nombre'] ?? 'No disponible'}'),
                  Text('Apellido: ${profileData['apellido'] ?? 'No disponible'}'),
                  Text('Username: ${profileData['username'] ?? 'No disponible'}'),
                  Text('Email: ${profileData['email'] ?? 'No disponible'}'),
                  // Puedes mostrar más campos según la estructura de tu respuesta JSON
                ],
              ),
  ),
);
}
}