import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zonix/models/commerce_product.dart';
import 'package:zonix/features/services/commerce_product_service.dart';
import '../../utils/app_colors.dart';
import 'package:zonix/config/app_config.dart';

/// Formulario de farmacia para crear/editar un producto / medicamento
/// con sus atributos farmacéuticos (principio activo, presentación,
/// registro INHRR, Rx, cadena de frío, etc.).
class CommerceProductFormPage extends StatefulWidget {
  const CommerceProductFormPage({
    super.key,
    this.product,
  });

  final CommerceProduct? product;

  @override
  State<CommerceProductFormPage> createState() =>
      _CommerceProductFormPageState();
}

class _CommerceProductFormPageState extends State<CommerceProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  // Pharma
  final _activeIngredientController = TextEditingController();
  final _concentrationController = TextEditingController();
  final _presentationController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _healthRegistryController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _atcCodeController = TextEditingController();

  String? _dosageForm;
  String? _prescriptionType;
  bool _requiresPrescription = false;
  bool _controlledSubstance = false;
  bool _coldChain = false;

  bool _available = true;
  bool _saving = false;
  File? _imageFile;
  String? _existingImagePath;

  static const _dosageForms = <String, String>{
    'tablet': 'Tabletas',
    'capsule': 'Cápsulas',
    'syrup': 'Jarabe',
    'suspension': 'Suspensión',
    'injection': 'Inyectable',
    'cream': 'Crema',
    'ointment': 'Ungüento',
    'gel': 'Gel',
    'drops': 'Gotas',
    'patch': 'Parches',
    'suppository': 'Supositorios',
    'inhaler': 'Inhalador',
    'powder': 'Polvo',
    'solution': 'Solución',
    'spray': 'Spray',
    'device': 'Dispositivo',
    'other': 'Otro',
  };

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    if (p != null) {
      _nameController.text = p.name;
      _descController.text = p.description;
      _priceController.text = p.price.toString();
      _stockController.text = p.stock?.toString() ?? '';
      _available = p.available;
      _existingImagePath = p.image;
      _activeIngredientController.text = p.activeIngredient ?? '';
      _concentrationController.text = p.concentration ?? '';
      _presentationController.text = p.presentation ?? '';
      _manufacturerController.text = p.manufacturer ?? '';
      _healthRegistryController.text = p.healthRegistry ?? '';
      _barcodeController.text = p.barcode ?? '';
      _atcCodeController.text = p.atcCode ?? '';
      _dosageForm = p.dosageForm;
      _prescriptionType = p.prescriptionType;
      _requiresPrescription = p.requiresPrescription;
      _controlledSubstance = p.controlledSubstance;
      _coldChain = p.coldChain;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _activeIngredientController.dispose();
    _concentrationController.dispose();
    _presentationController.dispose();
    _manufacturerController.dispose();
    _healthRegistryController.dispose();
    _barcodeController.dispose();
    _atcCodeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (xfile != null && mounted) {
      setState(() => _imageFile = File(xfile.path));
    }
  }

  String _imageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    final base = AppConfig.apiUrl.replaceAll('/api', '');
    return path.startsWith('/') ? '$base$path' : '$base/storage/$path';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_requiresPrescription && _prescriptionType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Selecciona el tipo de receta (común, retenida o especial).')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final data = <String, dynamic>{
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'available': _available,
        'stock': int.tryParse(_stockController.text),
        // Pharma
        'active_ingredient': _activeIngredientController.text.trim().isEmpty
            ? null
            : _activeIngredientController.text.trim(),
        'dosage_form': _dosageForm,
        'concentration': _concentrationController.text.trim().isEmpty
            ? null
            : _concentrationController.text.trim(),
        'presentation': _presentationController.text.trim().isEmpty
            ? null
            : _presentationController.text.trim(),
        'manufacturer': _manufacturerController.text.trim().isEmpty
            ? null
            : _manufacturerController.text.trim(),
        'health_registry': _healthRegistryController.text.trim().isEmpty
            ? null
            : _healthRegistryController.text.trim(),
        'barcode': _barcodeController.text.trim().isEmpty
            ? null
            : _barcodeController.text.trim(),
        'atc_code': _atcCodeController.text.trim().isEmpty
            ? null
            : _atcCodeController.text.trim(),
        'requires_prescription': _requiresPrescription,
        'prescription_type':
            _requiresPrescription ? _prescriptionType : null,
        'controlled_substance': _controlledSubstance,
        'cold_chain': _coldChain,
      };
      if (widget.product == null) {
        await CommerceProductService.createProduct(data, imageFile: _imageFile);
      } else {
        await CommerceProductService.updateProduct(
          widget.product!.id,
          data,
          imageFile: _imageFile,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Producto guardado'),
            backgroundColor: AppColors.statusSuccess,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Error: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: AppColors.statusError,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar producto' : 'Nuevo producto'),
      ),
      body: _saving
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                        child: _imageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child:
                                    Image.file(_imageFile!, fit: BoxFit.cover),
                              )
                            : _existingImagePath != null &&
                                    _existingImagePath!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      _imageUrl(_existingImagePath),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.add_a_photo,
                                        size: 48,
                                      ),
                                    ),
                                  )
                                : const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_a_photo, size: 48),
                                        SizedBox(height: 8),
                                        Text('Tap para agregar imagen'),
                                      ],
                                    ),
                                  ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _sectionTitle('Información comercial'),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre comercial',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            decoration: const InputDecoration(
                              labelText: 'Precio',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Requerido';
                              final n = double.tryParse(v);
                              if (n == null || n < 0) return 'Precio inválido';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _stockController,
                            decoration: const InputDecoration(
                              labelText: 'Stock (opcional)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Disponible para la venta'),
                      value: _available,
                      onChanged: (v) => setState(() => _available = v),
                    ),
                    const SizedBox(height: 16),
                    _sectionTitle('Identificación farmacéutica'),
                    TextFormField(
                      controller: _activeIngredientController,
                      decoration: const InputDecoration(
                        labelText: 'Principio activo',
                        helperText: 'Ej: paracetamol, amoxicilina',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _dosageForm,
                      decoration: const InputDecoration(
                        labelText: 'Forma farmacéutica',
                        border: OutlineInputBorder(),
                      ),
                      items: _dosageForms.entries
                          .map((e) => DropdownMenuItem(
                                value: e.key,
                                child: Text(e.value),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _dosageForm = v),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _concentrationController,
                            decoration: const InputDecoration(
                              labelText: 'Concentración',
                              helperText: 'Ej: 500mg',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _presentationController,
                            decoration: const InputDecoration(
                              labelText: 'Presentación',
                              helperText: 'Ej: caja x 20 tabletas',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _manufacturerController,
                      decoration: const InputDecoration(
                        labelText: 'Laboratorio fabricante',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _sectionTitle('Regulación y trazabilidad'),
                    TextFormField(
                      controller: _healthRegistryController,
                      decoration: const InputDecoration(
                        labelText: 'Registro INHRR',
                        helperText: 'Ej: E.F. 12345',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _barcodeController,
                            decoration: const InputDecoration(
                              labelText: 'Código (EAN)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _atcCodeController,
                            decoration: const InputDecoration(
                              labelText: 'Código ATC',
                              helperText: 'Opcional',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _sectionTitle('Reglas de despacho'),
                    SwitchListTile(
                      title: const Text('Requiere receta médica (Rx)'),
                      subtitle: const Text(
                          'El comprador debe subir una receta antes del pago.'),
                      value: _requiresPrescription,
                      onChanged: (v) => setState(() {
                        _requiresPrescription = v;
                        if (!v) _prescriptionType = null;
                      }),
                    ),
                    if (_requiresPrescription)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 12),
                        child: DropdownButtonFormField<String>(
                          value: _prescriptionType,
                          decoration: const InputDecoration(
                            labelText: 'Tipo de receta',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                                value: 'common', child: Text('Común')),
                            DropdownMenuItem(
                                value: 'retained', child: Text('Retenida')),
                            DropdownMenuItem(
                                value: 'special', child: Text('Especial')),
                          ],
                          onChanged: (v) => setState(() => _prescriptionType = v),
                        ),
                      ),
                    SwitchListTile(
                      title: const Text('Sustancia controlada'),
                      subtitle: const Text(
                          'Psicotrópico / opioide. Requiere receta retenida.'),
                      value: _controlledSubstance,
                      onChanged: (v) => setState(() {
                        _controlledSubstance = v;
                        if (v) {
                          _requiresPrescription = true;
                          _prescriptionType ??= 'retained';
                        }
                      }),
                    ),
                    SwitchListTile(
                      title: const Text('Cadena de frío (2-8°C)'),
                      subtitle: const Text(
                          'Insulinas, biológicos, vacunas. Restringe modos de delivery.'),
                      value: _coldChain,
                      onChanged: (v) => setState(() => _coldChain = v),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandTeal,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Guardar producto'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.brandNavy,
        ),
      ),
    );
  }
}
