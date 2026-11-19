import 'package:flutter/material.dart';
import '../models/medico.dart';
import '../services/medico_service.dart';

class MedicosScreen extends StatefulWidget {
  const MedicosScreen({super.key});

  @override
  State<MedicosScreen> createState() => _MedicosScreenState();
}

class _MedicosScreenState extends State<MedicosScreen> {
  late MedicoService _medicoService;
  late TextEditingController _urlController;

  List<Medico> _medicos = [];
  List<Medico> _medicosFiltrados = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _medicoService = MedicoService();
    _urlController = TextEditingController(text: _medicoService.baseUrl);
    _cargarMedicos();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _cargarMedicos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final medicos = await _medicoService.getMedicos();
      setState(() {
        _medicos = medicos;
        _filtrarMedicos(_searchQuery);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _mostrarSnackBar('Error al conectar con la API: $e', isError: true);
    }
  }

  void _filtrarMedicos(String query) {
    _searchQuery = query;
    setState(() {
      if (query.isEmpty) {
        _medicosFiltrados = _medicos;
      } else {
        _medicosFiltrados = _medicos.where((medico) {
          final queryLower = query.toLowerCase();
          return medico.nombreCompleto.toLowerCase().contains(queryLower) ||
              medico.especialidad.toLowerCase().contains(queryLower) ||
              medico.direccion.toLowerCase().contains(queryLower);
        }).toList();
      }
    });
  }

  void _mostrarSnackBar(String mensaje, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // Diálogo para cambiar la URL de la API
  void _mostrarDialogoConfiguracionUrl() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.settings_ethernet, color: Colors.indigo),
              SizedBox(width: 8),
              Text('Configurar URL API'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ingresa la dirección base de tu API .NET:',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'URL de la API',
                  hintText: 'http://localhost:5000/api/medicos',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '• Emulador Android: http://10.0.2.2:5000/api/medicos\n'
                '• Windows / Web / Chrome: http://localhost:5000/api/medicos\n'
                '• Dispositivo Físico: http://<IP_TU_PC>:5000/api/medicos',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _medicoService.baseUrl = _urlController.text.trim();
                });
                Navigator.pop(context);
                _cargarMedicos();
              },
              child: const Text('Guardar y Probar'),
            ),
          ],
        );
      },
    );
  }

  // Diálogo para Agregar o Editar Médico
  void _mostrarFormularioMedico({Medico? medicoExistente}) {
    final bool esEdicion = medicoExistente != null;
    final formKey = GlobalKey<FormState>();

    final nombreCtrl = TextEditingController(text: medicoExistente?.nombre ?? '');
    final aPaternoCtrl = TextEditingController(text: medicoExistente?.aPaterno ?? '');
    final aMaternoCtrl = TextEditingController(text: medicoExistente?.aMaterno ?? '');
    final telefonoCtrl = TextEditingController(text: medicoExistente?.telefono ?? '');
    final direccionCtrl = TextEditingController(text: medicoExistente?.direccion ?? '');
    final especialidadCtrl = TextEditingController(text: medicoExistente?.especialidad ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        esEdicion ? 'Editar Médico' : 'Nuevo Médico',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: nombreCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) =>
                        val == null || val.trim().isEmpty ? 'Ingrese un nombre' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: aPaternoCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Apellido Paterno',
                            prefixIcon: Icon(Icons.badge),
                            border: OutlineInputBorder(),
                          ),
                          validator: (val) =>
                              val == null || val.trim().isEmpty ? 'Ingrese apellido paterno' : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: aMaternoCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Apellido Materno',
                            prefixIcon: Icon(Icons.badge_outlined),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: especialidadCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Especialidad',
                      prefixIcon: Icon(Icons.local_hospital),
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) =>
                        val == null || val.trim().isEmpty ? 'Ingrese una especialidad' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: telefonoCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: direccionCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Dirección',
                      prefixIcon: Icon(Icons.home),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                      ),
                      icon: Icon(esEdicion ? Icons.save : Icons.add),
                      label: Text(esEdicion ? 'Guardar Cambios' : 'Registrar Médico'),
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;

                        final idTarget = medicoExistente?.idMedico;
                        if (esEdicion && idTarget == null) {
                          _mostrarSnackBar('Error: El médico no posee un ID válido', isError: true);
                          return;
                        }

                        final nuevoMedico = Medico(
                          idMedico: idTarget,
                          nombre: nombreCtrl.text.trim(),
                          aPaterno: aPaternoCtrl.text.trim(),
                          aMaterno: aMaternoCtrl.text.trim(),
                          telefono: telefonoCtrl.text.trim(),
                          direccion: direccionCtrl.text.trim(),
                          especialidad: especialidadCtrl.text.trim(),
                          estatus: medicoExistente?.estatus ?? true,
                        );

                        Navigator.pop(context);

                        try {
                          if (esEdicion) {
                            await _medicoService.updateMedico(idTarget!, nuevoMedico);
                            _mostrarSnackBar('Médico actualizado correctamente');
                          } else {
                            await _medicoService.createMedico(nuevoMedico);
                            _mostrarSnackBar('Médico creado correctamente');
                          }
                          _cargarMedicos();
                        } catch (e) {
                          _mostrarSnackBar('Error al guardar: $e', isError: true);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Confirmar eliminación (Borrado Lógico)
  void _confirmarEliminacion(Medico medico) {
    if (medico.idMedico == null) {
      _mostrarSnackBar('Error: El médico no posee un ID válido', isError: true);
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text(
            '¿Está seguro de desactivar al médico "${medico.nombreCompleto}" (ID: ${medico.idMedico})? (Borrado lógico)',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await _medicoService.deleteMedico(medico.idMedico!);
                  _mostrarSnackBar('Médico desactivado correctamente');
                  _cargarMedicos();
                } catch (e) {
                  _mostrarSnackBar('Error al eliminar: $e', isError: true);
                }
              },
              child: const Text('Desactivar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRUD Médicos'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Configurar URL API',
            onPressed: _mostrarDialogoConfiguracionUrl,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar',
            onPressed: _cargarMedicos,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda e información de API
          Container(
            padding: const EdgeInsets.all(12.0),
            color: Colors.indigo.shade50,
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.link, size: 16, color: Colors.indigo),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'API: ${_medicoService.baseUrl}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.indigo,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  onChanged: _filtrarMedicos,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre, especialidad o dirección...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lista de médicos
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _medicosFiltrados.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_off, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No hay médicos registrados'
                                  : 'No se encontraron resultados para "$_searchQuery"',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _cargarMedicos,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(10),
                          itemCount: _medicosFiltrados.length,
                          itemBuilder: (context, index) {
                            final medico = _medicosFiltrados[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.indigo.shade100,
                                  child: Text(
                                    medico.nombre.isNotEmpty ? medico.nombre[0].toUpperCase() : 'M',
                                    style: TextStyle(
                                      color: Colors.indigo.shade900,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  '${medico.nombreCompleto} (ID: ${medico.idMedico ?? 'N/A'})',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.local_hospital, size: 14, color: Colors.teal),
                                        const SizedBox(width: 4),
                                        Text(medico.especialidad),
                                      ],
                                    ),
                                    if (medico.telefono.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          const Icon(Icons.phone, size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(medico.telefono, style: const TextStyle(fontSize: 12)),
                                        ],
                                      ),
                                    ],
                                    if (medico.direccion.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          const Icon(Icons.home, size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              medico.direccion,
                                              style: const TextStyle(fontSize: 12),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                                isThreeLine: true,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      tooltip: 'Editar',
                                      onPressed: () => _mostrarFormularioMedico(
                                        medicoExistente: medico,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      tooltip: 'Desactivar',
                                      onPressed: () => _confirmarEliminacion(medico),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarFormularioMedico(),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Médico'),
      ),
    );
  }
}
