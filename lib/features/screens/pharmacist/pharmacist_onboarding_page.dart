import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import 'package:zonix/config/app_config.dart';
import 'package:zonix/helpers/auth_helper.dart';

/// Registro de datos colegiados (MPPS, licencia, título opcional).
/// POST `/api/pharmacist/onboarding` (multipart).
class PharmacistOnboardingPage extends StatefulWidget {
  const PharmacistOnboardingPage({super.key});

  @override
  State<PharmacistOnboardingPage> createState() =>
      _PharmacistOnboardingPageState();
}

class _PharmacistOnboardingPageState extends State<PharmacistOnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  final _mpps = TextEditingController();
  final _license = TextEditingController();
  final _notes = TextEditingController();
  DateTime? _expiresAt;
  File? _titleFile;
  bool _saving = false;

  @override
  void dispose() {
    _mpps.dispose();
    _license.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickTitleFile() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Foto del título (cámara)'),
              onTap: () => Navigator.pop(ctx, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Foto del título (galería)'),
              onTap: () => Navigator.pop(ctx, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('PDF del título'),
              onTap: () => Navigator.pop(ctx, 'pdf'),
            ),
          ],
        ),
      ),
    );
    if (choice == null) return;
    if (choice == 'pdf') {
      final r = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
      );
      final path = r?.files.single.path;
      if (path != null && mounted) setState(() => _titleFile = File(path));
      return;
    }
    final picker = ImagePicker();
    final src = choice == 'camera' ? ImageSource.camera : ImageSource.gallery;
    final picked = await picker.pickImage(source: src, imageQuality: 85);
    if (picked != null && mounted) setState(() => _titleFile = File(picked.path));
  }

  Future<void> _pickExpiry() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _expiresAt ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 15)),
    );
    if (d != null && mounted) setState(() => _expiresAt = d);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_expiresAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Selecciona la fecha de vencimiento de tu licencia (debe ser futura).')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final token = await AuthHelper.getToken();
      final uri = Uri.parse('${AppConfig.apiUrl}/api/pharmacist/onboarding');
      final req = http.MultipartRequest('POST', uri);
      if (token != null && token.isNotEmpty) {
        req.headers['Authorization'] = 'Bearer $token';
      }
      req.headers['Accept'] = 'application/json';
      req.fields['mpps_number'] = _mpps.text.trim();
      final lic = _license.text.trim();
      if (lic.isNotEmpty) {
        req.fields['college_license_number'] = lic;
      }
      req.fields['license_expires_at'] =
          _expiresAt!.toIso8601String().substring(0, 10);
      if (_notes.text.trim().isNotEmpty) {
        req.fields['notes'] = _notes.text.trim();
      }
      if (_titleFile != null) {
        final path = _titleFile!.path;
        final ext = path.split('.').last.toLowerCase();
        final mime =
            ext == 'pdf' ? 'application/pdf' : 'image/jpeg';
        req.files.add(await http.MultipartFile.fromPath(
          'title_image',
          path,
          contentType: MediaType.parse(mime),
        ));
      }

      final streamed = await req.send();
      final res = await http.Response.fromStream(streamed);
      if (!mounted) return;
      if (res.statusCode >= 200 && res.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Datos enviados. Un administrador validará tu colegiación MPPS.'),
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'No se pudo guardar (${res.statusCode}). Revisa los datos.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro farmacéutico colegiado'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Completa tu registro para aparecer como farmacéutico responsable y validar recetas.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mpps,
                decoration: const InputDecoration(
                  labelText: 'Número MPPS',
                  hintText: 'Según registro MPPS vigente',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _license,
                decoration: const InputDecoration(
                  labelText: 'Número de colegiación / licencia (opcional)',
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_expiresAt == null
                    ? 'Vencimiento de licencia colegial *'
                    : 'Licencia vence: ${_expiresAt!.toIso8601String().substring(0, 10)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickExpiry,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notes,
                decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _pickTitleFile,
                icon: const Icon(Icons.attach_file),
                label: Text(_titleFile == null
                    ? 'Adjuntar título o cédula profesional (opcional)'
                    : 'Archivo: ${_titleFile!.path.split('/').last}'),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _submit,
                child: _saving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Enviar datos'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
