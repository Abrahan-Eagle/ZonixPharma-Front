import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:zonix/features/services/prescription_service.dart';
import 'package:zonix/features/utils/app_colors.dart';
import 'package:zonix/models/prescription.dart';

/// Pantalla buyer para subir una receta médica vinculada a un pedido Rx.
class PrescriptionUploadPage extends StatefulWidget {
  final int orderId;

  const PrescriptionUploadPage({super.key, required this.orderId});

  @override
  State<PrescriptionUploadPage> createState() => _PrescriptionUploadPageState();
}

class _PrescriptionUploadPageState extends State<PrescriptionUploadPage> {
  final _formKey = GlobalKey<FormState>();
  final _doctorController = TextEditingController();
  final _licenseController = TextEditingController();
  final _specialtyController = TextEditingController();
  DateTime? _issuedAt;
  String _prescriptionType = Prescription.typeCommon;
  File? _selectedFile;
  bool _submitting = false;

  @override
  void dispose() {
    _doctorController.dispose();
    _licenseController.dispose();
    _specialtyController.dispose();
    super.dispose();
  }

  Future<void> _pickAttachment() async {
    final source = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Tomar foto de la receta'),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Elegir desde galería'),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Adjuntar PDF'),
              onTap: () => Navigator.pop(context, 'pdf'),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    if (source == 'pdf') {
      final r = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
      );
      final path = r?.files.single.path;
      if (path != null) {
        setState(() => _selectedFile = File(path));
      }
      return;
    }

    final picker = ImagePicker();
    final imgSource =
        source == 'camera' ? ImageSource.camera : ImageSource.gallery;
    final picked = await picker.pickImage(source: imgSource, imageQuality: 85);
    if (picked != null) {
      setState(() => _selectedFile = File(picked.path));
    }
  }

  Future<void> _pickIssuedAt() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _issuedAt ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _issuedAt = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Adjunta una foto o PDF de la receta médica.')),
      );
      return;
    }

    setState(() => _submitting = true);
    final service = context.read<PrescriptionService>();
    final result = await service.uploadPrescription(
      orderId: widget.orderId,
      prescribingDoctorName: _doctorController.text.trim(),
      prescribingDoctorLicense: _licenseController.text.trim().isEmpty
          ? null
          : _licenseController.text.trim(),
      prescribingDoctorSpecialty: _specialtyController.text.trim().isEmpty
          ? null
          : _specialtyController.text.trim(),
      issuedAt: _issuedAt,
      prescriptionType: _prescriptionType,
      filePath: _selectedFile!.path,
      fileName: _selectedFile!.path.split('/').last,
      fileMime: _selectedFile!.path.toLowerCase().endsWith('.pdf')
          ? 'application/pdf'
          : 'image/jpeg',
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Receta enviada. El farmacéutico la revisará en breve.')),
      );
      Navigator.of(context).pop(result);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(service.error ?? 'No se pudo enviar la receta.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Subir receta médica')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.brandMint.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.health_and_safety,
                        color: AppColors.brandTealDeep),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tu receta será revisada por el farmacéutico colegiado responsable de la farmacia despachadora antes de continuar con el pago.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _photoPicker(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _doctorController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del médico prescriptor',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _licenseController,
                decoration: const InputDecoration(
                  labelText: 'MPPS / matrícula del médico (opcional)',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _specialtyController,
                decoration: const InputDecoration(
                  labelText: 'Especialidad del médico (opcional)',
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_issuedAt == null
                    ? 'Fecha de emisión de la receta (opcional)'
                    : 'Receta emitida el ${_issuedAt!.toLocal().toIso8601String().substring(0, 10)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickIssuedAt,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _prescriptionType,
                decoration:
                    const InputDecoration(labelText: 'Tipo de receta'),
                items: const [
                  DropdownMenuItem(
                      value: Prescription.typeCommon, child: Text('Común')),
                  DropdownMenuItem(
                      value: Prescription.typeRetained, child: Text('Retenida')),
                  DropdownMenuItem(
                      value: Prescription.typeSpecial, child: Text('Especial')),
                ],
                onChanged: (v) => setState(
                    () => _prescriptionType = v ?? Prescription.typeCommon),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send),
                label: Text(_submitting ? 'Enviando...' : 'Enviar receta'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _photoPicker() {
    return InkWell(
      onTap: _pickAttachment,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.brandSurfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.brandStrokeLight),
        ),
        child: _selectedFile == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.cloud_upload,
                      size: 48, color: AppColors.brandTealDeep),
                  SizedBox(height: 8),
                  Text('Toca para adjuntar foto o PDF de la receta'),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _selectedFile!.path.toLowerCase().endsWith('.pdf')
                    ? const Center(
                        child: Icon(Icons.picture_as_pdf,
                            size: 64, color: AppColors.brandTealDeep))
                    : Image.file(_selectedFile!, fit: BoxFit.cover),
              ),
      ),
    );
  }
}
