import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/medico.dart';

class MedicoService {
  /// Base URL de la API. 
  /// - Para Emulador Android: 'http://10.0.2.2:5000/api/medicos'
  /// - Para Navegador Web o Escritorio (Windows/Mac/Linux): 'http://localhost:5000/api/medicos'
  /// - Para Dispositivo Físico: IP de tu PC (ej: 'http://192.168.1.14:5000/api/medicos')
  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://192.168.137.128:5000/api/medicos';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000/api/medicos';
    } else {
      return 'http://192.168.137.128:5000/api/medicos';
    }
  }

  String baseUrl;

  MedicoService({String? customBaseUrl})
      : baseUrl = customBaseUrl ?? defaultBaseUrl;

  /// Elimina barras diagonales al final de la URL para evitar // en las rutas
  String get _sanitizedBaseUrl {
    String url = baseUrl.trim();
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return url;
  }

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
      };

  // GET: api/medicos (Obtener todos los médicos activos)
  Future<List<Medico>> getMedicos() async {
    final response = await http.get(
      Uri.parse(_sanitizedBaseUrl),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Medico.fromJson(item)).toList();
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  // GET: api/medicos/{id}
  Future<Medico> getMedico(int id) async {
    final response = await http.get(
      Uri.parse('$_sanitizedBaseUrl/$id'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return Medico.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('HTTP ${response.statusCode}: Médico no encontrado');
    }
  }

  // POST: api/medicos (Crear médico)
  Future<Medico> createMedico(Medico medico) async {
    final Map<String, dynamic> bodyMap = medico.toJson();
    bodyMap['estatus'] = true;
    bodyMap['Estatus'] = true;

    final response = await http.post(
      Uri.parse(_sanitizedBaseUrl),
      headers: _headers,
      body: jsonEncode(bodyMap),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        return Medico.fromJson(jsonDecode(response.body));
      }
      return medico;
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  // PUT: api/medicos/{id} (Actualizar médico)
  Future<void> updateMedico(int id, Medico medico) async {
    final Map<String, dynamic> bodyMap = medico.toJson();
    
    // Es crítico incluir idMedico e IdMedico coincidiendo con el id de la URL
    bodyMap['idMedico'] = id;
    bodyMap['IdMedico'] = id;

    final response = await http.put(
      Uri.parse('$_sanitizedBaseUrl/$id'),
      headers: _headers,
      body: jsonEncode(bodyMap),
    );

    if (response.statusCode != 204 && response.statusCode != 200 && response.statusCode != 202) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  // DELETE: api/medicos/{id} (Borrado lógico)
  Future<void> deleteMedico(int id) async {
    final response = await http.delete(
      Uri.parse('$_sanitizedBaseUrl/$id'),
      headers: _headers,
    );

    if (response.statusCode != 204 && response.statusCode != 200 && response.statusCode != 202) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }
}
