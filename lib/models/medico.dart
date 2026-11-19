class Medico {
  final int? idMedico;
  final String nombre;
  final String aPaterno;
  final String aMaterno;
  final String telefono;
  final String direccion;
  final String especialidad;
  final bool estatus;

  Medico({
    this.idMedico,
    required this.nombre,
    this.aPaterno = '',
    this.aMaterno = '',
    this.telefono = '',
    this.direccion = '',
    required this.especialidad,
    this.estatus = true,
  });

  String get nombreCompleto {
    final apellidos = '$aPaterno $aMaterno'.trim();
    if (apellidos.isEmpty) return nombre;
    return '$nombre $apellidos';
  }

  factory Medico.fromJson(Map<String, dynamic> json) {
    return Medico(
      idMedico: json['idMedico'] ?? json['IdMedico'],
      nombre: json['nombre'] ?? json['Nombre'] ?? '',
      aPaterno: json['aPaterno'] ?? json['APaterno'] ?? json['apaterno'] ?? '',
      aMaterno: json['aMaterno'] ?? json['AMaterno'] ?? json['amaterno'] ?? '',
      telefono: json['telefono'] ?? json['Telefono'] ?? '',
      direccion: json['direccion'] ?? json['Direccion'] ?? '',
      especialidad: json['especialidad'] ?? json['Especialidad'] ?? '',
      estatus: json['estatus'] ?? json['Estatus'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'nombre': nombre,
      'aPaterno': aPaterno,
      'aMaterno': aMaterno,
      'telefono': telefono,
      'direccion': direccion,
      'especialidad': especialidad,
      'estatus': estatus,
      // Alias en PascalCase para C# ASP.NET Core Model Binding
      'Nombre': nombre,
      'APaterno': aPaterno,
      'AMaterno': aMaterno,
      'Telefono': telefono,
      'Direccion': direccion,
      'Especialidad': especialidad,
      'Estatus': estatus,
    };
    if (idMedico != null) {
      data['idMedico'] = idMedico;
      data['IdMedico'] = idMedico;
    }
    return data;
  }
}
