import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://api-inti-killa.vercel.app/api';

  static Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/empleado/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final token = responseData['token'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('nombre', responseData['nombre']);
        await prefs.setString('apellido', responseData['apellido']);
        await prefs.setString('username', responseData['username']);
        await prefs.setString('_id', responseData['_id']);
        await prefs.setString('email', responseData['email']);
        return true;
      } else {
        print('Error de autenticación: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error en la solicitud HTTP: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> fetchProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/empleado/informacion'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error al cargar perfil: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
        throw Exception('Failed to load profile data');
      }
    } catch (e) {
      print('Error en la solicitud HTTP: $e');
      throw e;
    }
  }

  static Future<List<dynamic>> fetchClientesFromApi(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/clientes'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error al cargar los clientes: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
        throw Exception('Error al cargar los clientes desde la API');
      }
    } catch (e) {
      print('Error en la solicitud HTTP: $e');
      throw e;
    }
  }

 static Future<Map<String, dynamic>> agregarCliente({
    required String token,
    required Map<String, dynamic> cliente,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cliente/registro'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(cliente),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Response body: $responseData');
        return responseData;
      } else {
        print('Error al agregar el cliente: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
        throw Exception('Error al agregar el cliente');
      }
    } catch (e) {
      print('Error en la solicitud HTTP: $e');
      throw e;
    }
  }


  static Future<bool> guardarCliente({
    required String token,
    required String nombre,
    required String cedula,
    required String telefono,
    required String direccion,
    required String email,
    required String tipodoc, // Añadir el campo tipodoc aquí
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cliente/registro'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'nombre': nombre,
          'cedula': cedula,
          'telefono': telefono,
          'direccion': direccion,
          'email': email,
          'tipodoc': tipodoc, // Asegúrate de incluir el campo tipodoc
        }),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        if (response.statusCode == 400) {
          final responseData = json.decode(response.body);
          if (responseData['msg'] == 'Lo sentimos, la cédula ya se encuentra registrada') {
            print('Error: Cédula ya registrada');
            throw Exception('La cédula ya se encuentra registrada');
          }
        }
        print('Error al guardar el cliente: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
        throw Exception('Error al guardar el cliente');
      }
    } catch (e) {
      print('Error en la solicitud HTTP: $e');
      throw e;
    }
  }

  static Future<bool> modificarCliente({
    required String token,
    required String id,
    required String nombre,
    required String cedula,
    required String telefono,
    required String direccion,
    required String email,
    required String tipodoc, // Añadir el campo tipodoc aquí
  }) async {
    try {
      if (id.isEmpty) {
        throw Exception('El ID del cliente no puede estar vacío');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/cliente/actualizar/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'nombre': nombre,
          'cedula': cedula,
          'telefono': telefono,
          'direccion': direccion,
          'email': email,
          'tipodoc': tipodoc, // Añadir el campo tipodoc aquí
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error al actualizar el cliente: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
        throw Exception('Error al actualizar el cliente');
      }
    } catch (e) {
      print('Error en la solicitud HTTP: $e');
      throw e;
    }
  }

  static Future<bool> eliminarCliente({
    required String token,
    required String id,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/cliente/eliminar/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error al eliminar el cliente: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
        throw Exception('Error al eliminar el cliente');
      }
    } catch (e) {
      print('Error en la solicitud HTTP: $e');
      throw e;
    }
  }

  static Future<bool> recuperarUsuario(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/empleado/recuperar-username'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        print('Usuario recuperado exitosamente.');
        return true;
      } else {
        print('Error al recuperar el usuario: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error en la solicitud HTTP: $e');
      return false;
    }
  }

  static Future<bool> recuperarPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/empleado/recuperar-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error al recuperar contraseña: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error en la solicitud HTTP: $e');
      return false;
    }
  }

  static Future<bool> verificarCodigoYActualizarPassword(String token, String newPassword, String confirmNewPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/empleado/nuevo-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'token': token,
          'password': newPassword,
          'confirmpassword': confirmNewPassword,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error al actualizar contraseña: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error en la solicitud HTTP: $e');
      return false;
    }
  }

  // PROFORMAS
  static Future<bool> guardarProforma({
    required String token,
    required String idCliente,
    required String idEmpleado,
    required List<Map<String, dynamic>> productos,
    required double totalSinImpuestos,
    required double totalDescuento,
    required double totalImpuestoValor,
    required double importeTotal,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/proforma/registro'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'id_cliente': idCliente,
          'id_empleado': idEmpleado,
          'products': productos,
          'totalSinImpuestos': totalSinImpuestos,
          'totalDescuento': totalDescuento,
          'totalImpuestoValor': totalImpuestoValor,
          'importeTotal': importeTotal,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error al guardar la proforma: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
        throw Exception('Error al guardar la proforma');
      }
    } catch (e) {
      print('Error en la solicitud HTTP: $e');
      throw e;
    }
  }

  static Future<List<dynamic>> fetchProformas(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/proformas'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error al cargar las proformas: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
        throw Exception('Error al cargar las proformas desde la API');
      }
    } catch (e) {
      print('Error en la solicitud HTTP: $e');
      throw e;
    }
  }

  static Future<List<dynamic>> fetchClientes(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/clientes'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error al cargar los clientes: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
        throw Exception('Error al cargar los clientes desde la API');
      }
    } catch (e) {
      print('Error en la solicitud HTTP: $e');
      throw e;
    }
  }

  static Future<Map<String, dynamic>> agregarProforma({
    required String token,
    required String idCliente,
    required String idEmpleado,
    required List<Map<String, dynamic>> productos,
    required double totalSinImpuestos,
    required double totalDescuento,
    required double totalImpuestoValor,
    required double importeTotal,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/proforma/registro'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'id_cliente': idCliente,
          'id_empleado': idEmpleado,
          'products': productos,
          'totalSinImpuestos': totalSinImpuestos,
          'totalDescuento': totalDescuento,
          'totalImpuestoValor': totalImpuestoValor,
          'importeTotal': importeTotal,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error al guardar la proforma: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
        throw Exception('Error al guardar la proforma');
      }
    } catch (e) {
      print('Error en la solicitud HTTP: $e');
      throw e;
    }
  }

  static Future<bool> modificarProforma({
    required String token,
    required String idProforma,
    required String idCliente,
    required String idEmpleado,
    required List<Map<String, dynamic>> productos,
    required double totalSinImpuestos,
    required double totalDescuento,
    required double totalImpuestoValor,
    required double importeTotal,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/proforma/actualizar/$idProforma'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'id_cliente': idCliente,
          'id_empleado': idEmpleado,
          'products': productos,
          'totalSinImpuestos': totalSinImpuestos,
          'totalDescuento': totalDescuento,
          'totalImpuestoValor': totalImpuestoValor,
          'importeTotal': importeTotal,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error al actualizar la proforma: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
        throw Exception('Error al actualizar la proforma');
      }
    } catch (e) {
      print('Error en la solicitud HTTP: $e');
      throw e;
    }
  }

  // Facturas
  static Future<Map<String, dynamic>> agregarFactura({
    required String token,
    required String idCliente,
    required String idEmpleado,
    required List<Map<String, dynamic>> productos,
    required double totalSinImpuestos,
    required double totalDescuento,
    required double totalImpuestoValor,
    required double importeTotal,
    required String metodoPago,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/factura/generate-invoice'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'id_cliente': idCliente,
          'id_empleado': idEmpleado,
          'products': productos,
          'totalSinImpuestos': totalSinImpuestos,
          'totalDescuento': totalDescuento,
          'totalImpuestoValor': totalImpuestoValor,
          'importeTotal': importeTotal,
          'formaPago': metodoPago,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error al guardar la factura: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
        throw Exception('Error al guardar la factura');
      }
    } catch (e) {
      print('Error en la solicitud HTTP: $e');
      throw e;
    }
  }

  static Future<List<dynamic>> fetchFacturas(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/facturas'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error al cargar las facturas: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
        throw Exception('Error al cargar las facturas desde la API');
      }
    } catch (e) {
      print('Error en la solicitud HTTP: $e');
      throw e;
    }
  }



}
